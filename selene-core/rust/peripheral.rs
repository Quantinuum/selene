//! A stateful quantum peripheral, exposed as an instance and a C function table.
//!
//! The runtime sees batches and measurement results. The host decides whether
//! those operations are implemented by a simulator, an error model, or wrappers.
use anyhow::{Result, anyhow};
use std::{ffi, marker::PhantomData, path::Path, rc::Rc};

use crate::{
    error_model::{BatchResult, plugin::BatchResultBuilder},
    operation::{
        BatchOperation,
        plugin::{BatchBuilder, BatchExtractor, RuntimeExtractOperationHandle},
    },
    utils::check_errno,
};

/// Requirements for a temporary borrow. Initialise struct_size to sizeof this
/// structure. Future versions may add fields at the end.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct PeripheralBorrowRequest {
    pub struct_size: u64,
    /// Complete all work ordered before this borrow, including publication of
    /// measurement results. This applies to the whole peripheral, not a subset
    /// of qubits. Unsupported requirements must fail before invoking the callback.
    pub force_flush: bool,
}

impl Default for PeripheralBorrowRequest {
    fn default() -> Self {
        Self {
            struct_size: size_of::<Self>() as u64,
            force_flush: false,
        }
    }
}

/// Invoke on the execution thread, with exclusive access for the duration of
/// the callback. Neither the peripheral nor context may be retained afterwards.
/// The callback returns zero on success and must not unwind through C.
pub type PeripheralBorrowCallback =
    unsafe extern "C" fn(context: *mut ffi::c_void, peripheral: QuantumPeripheralHandle) -> i32;

/// A borrowed peripheral. Copying this structure does not create another owner.
/// Calls must be exclusive and stay on the thread on which the host created it.
/// The instance, function table and operation/result buffers remain valid only
/// for the lifetime agreed with the host. Callbacks must not retain buffers.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct QuantumPeripheralHandle {
    pub instance: *mut ffi::c_void,
    pub interface: QuantumPeripheralOperationInterface,
}

/// A result sink borrowed for one execution call. Result identifiers are
/// supplied by the runtime in the corresponding measurement operations.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct PeripheralResultHandle {
    pub instance: *mut ffi::c_void,
    pub interface: PeripheralResultInterface,
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct PeripheralResultInterface {
    pub set_bool_result_fn: unsafe extern "C" fn(*mut ffi::c_void, u64, bool),
    pub set_u64_result_fn: unsafe extern "C" fn(*mut ffi::c_void, u64, u64),
}

/// Both function pointers are required and return zero on success. When
/// extracting a batch, supply a complete operation callback table, including
/// callbacks for operations this particular batch does not happen to contain.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct QuantumPeripheralOperationInterface {
    pub handle_operations_fn: unsafe extern "C" fn(
        *mut ffi::c_void,
        RuntimeExtractOperationHandle,
        PeripheralResultHandle,
    ) -> i32,
    pub dump_state_fn:
        unsafe extern "C" fn(*mut ffi::c_void, *const ffi::c_char, *const u64, u64) -> i32,
}

pub trait QuantumPeripheralInterface {
    fn handle_operations(&mut self, batch: BatchOperation) -> Result<BatchResult>;
    fn dump_state(&mut self, file: &Path, qubits: &[u64]) -> Result<()>;
}

/// Borrows a C peripheral without taking responsibility for destroying it.
/// This wrapper deliberately cannot be moved or shared between threads.
pub struct QuantumPeripheral<'a> {
    handle: QuantumPeripheralHandle,
    _borrow: PhantomData<&'a mut ()>,
    _thread: PhantomData<Rc<()>>,
}

impl<'a> QuantumPeripheral<'a> {
    /// # Safety
    /// The handle must be live and exclusively borrowed for 'a. Construct and
    /// use this wrapper only on the peripheral's execution thread.
    pub unsafe fn from_raw_parts(handle: QuantumPeripheralHandle) -> Self {
        Self {
            handle,
            _borrow: PhantomData,
            _thread: PhantomData,
        }
    }
}

impl QuantumPeripheralInterface for QuantumPeripheral<'_> {
    fn handle_operations(&mut self, batch: BatchOperation) -> Result<BatchResult> {
        let mut extractor = BatchExtractor::from_batch_operation(batch);
        let mut results = BatchResultBuilder::default();
        let sink = results.error_model_set_result();
        let sink = PeripheralResultHandle {
            instance: sink.instance,
            interface: PeripheralResultInterface {
                set_bool_result_fn: sink.interface.set_bool_result_fn,
                set_u64_result_fn: sink.interface.set_u64_result_fn,
            },
        };
        check_errno(
            unsafe {
                (self.handle.interface.handle_operations_fn)(
                    self.handle.instance,
                    extractor.runtime_batch_extraction(),
                    sink,
                )
            },
            || anyhow!("QuantumPeripheral: handling operations failed"),
        )?;
        Ok(results.finish())
    }

    fn dump_state(&mut self, file: &Path, qubits: &[u64]) -> Result<()> {
        let file = ffi::CString::new(
            file.to_str()
                .ok_or_else(|| anyhow!("State path is not UTF-8"))?,
        )?;
        check_errno(
            unsafe {
                (self.handle.interface.dump_state_fn)(
                    self.handle.instance,
                    file.as_ptr(),
                    qubits.as_ptr(),
                    qubits.len() as u64,
                )
            },
            || anyhow!("QuantumPeripheral: dumping state failed"),
        )
    }
}

/// Owns a Rust implementation and lends its C interface to a runtime.
/// Keep this adapter at a stable address while its handle is in use.
pub struct QuantumPeripheralFFIAdapter<T> {
    pub inner: T,
}

impl<T: QuantumPeripheralInterface> QuantumPeripheralFFIAdapter<T> {
    pub fn new(inner: T) -> Self {
        Self { inner }
    }

    pub fn ffi_interface(&mut self) -> QuantumPeripheralHandle {
        QuantumPeripheralHandle {
            instance: self as *mut Self as *mut ffi::c_void,
            interface: QuantumPeripheralOperationInterface {
                handle_operations_fn: Self::handle_operations,
                dump_state_fn: Self::dump_state,
            },
        }
    }

    unsafe extern "C" fn handle_operations(
        instance: *mut ffi::c_void,
        batch: RuntimeExtractOperationHandle,
        result: PeripheralResultHandle,
    ) -> i32 {
        crate::runtime::callback_result(|| {
            let this = unsafe { &mut *instance.cast::<Self>() };
            let mut builder = BatchBuilder::default();
            unsafe {
                (batch.interface.extract_fn)(batch.instance, builder.runtime_get_operation())
            };
            let results = this.inner.handle_operations(builder.finish())?;
            for value in results.bool_results {
                unsafe {
                    (result.interface.set_bool_result_fn)(
                        result.instance,
                        value.result_id,
                        value.value,
                    )
                };
            }
            for value in results.u64_results {
                unsafe {
                    (result.interface.set_u64_result_fn)(
                        result.instance,
                        value.result_id,
                        value.value,
                    )
                };
            }
            Ok(())
        })
    }

    unsafe extern "C" fn dump_state(
        instance: *mut ffi::c_void,
        file: *const ffi::c_char,
        qubits: *const u64,
        count: u64,
    ) -> i32 {
        crate::runtime::callback_result(|| {
            let this = unsafe { &mut *instance.cast::<Self>() };
            let file = unsafe { ffi::CStr::from_ptr(file) }.to_str()?;
            let qubits = if count == 0 {
                &[]
            } else {
                unsafe { std::slice::from_raw_parts(qubits, count as usize) }
            };
            this.inner.dump_state(Path::new(file), qubits)
        })
    }
}
