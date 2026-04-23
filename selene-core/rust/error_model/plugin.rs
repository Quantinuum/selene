use super::{
    BatchResult, BoolResult, ErrorModelAPIVersion, ErrorModelInterface, ErrorModelInterfaceFactory,
    U64Result,
};
use crate::runtime::BatchOperation;
use crate::utils::{MetricValue, check_errno, read_raw_metric, with_strings_to_cargs};
use anyhow::{Result, anyhow};
use libloading;
use std::ffi::OsStr;
use std::marker::PhantomData;
use std::{ffi, sync::Arc};

pub type ErrorModelInstance = *mut ffi::c_void;
pub type Errno = i32;

pub const ERROR_MODEL_DESCRIPTOR_ABI_NAME: &str = "selene.error_model.descriptor.v1";
pub const ERROR_MODEL_DESCRIPTOR_ABI_SPEC: &str =
    "em:init,exit?,shot_start,shot_end,handle_operations,get_metrics?";
pub const ERROR_MODEL_DESCRIPTOR_ABI_HASH: u64 =
    crate::fnv1a64(ERROR_MODEL_DESCRIPTOR_ABI_SPEC.as_bytes());
pub const ERROR_MODEL_DESCRIPTOR_SIGNATURE_MANIFEST: &str = "init:int(*)(void**,u64,u32,const char**);exit:int(*)(void*);shot_start:int(*)(void*,u64,u64);shot_end:int(*)(void*);handle_operations:int(*)(void*,void*,const RuntimeExtractOperationInterface*,void*,const SimulatorOperationInterface*,void*,const ErrorModelSetResultInterface*);get_metrics:int(*)(void*,u8,char*,u8*,u64*)";

#[repr(C)]
#[derive(Clone, Copy)]
pub struct ErrorModelPluginDescriptorV1 {
    pub struct_size: u64,
    pub api_version: u64,
    pub abi_magic: u64,
    pub abi_hash: u64,
    pub abi_name: *const ffi::c_char,
    pub signature_manifest: *const ffi::c_char,
    pub init_fn: unsafe extern "C" fn(
        handle: *mut ErrorModelInstance,
        n_qubits: u64,
        error_model_argc: u32,
        error_model_argv: *const *const ffi::c_char,
    ) -> Errno,
    pub exit_fn: Option<unsafe extern "C" fn(handle: ErrorModelInstance) -> Errno>,
    pub shot_start_fn: unsafe extern "C" fn(
        handle: ErrorModelInstance,
        shot_id: u64,
        error_model_seed: u64,
    ) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(handle: ErrorModelInstance) -> Errno,
    pub handle_operations_fn: unsafe extern "C" fn(
        handle: ErrorModelInstance,
        batch_instance: crate::runtime::plugin::RuntimeExtractOperationInstance,
        batch_interface: *const crate::runtime::plugin::RuntimeExtractOperationInterface,
        simulator_instance: crate::simulator::plugin::SimulatorInstance,
        simulator_interface: *const crate::simulator::inline::SimulatorOperationInterface,
        result_instance: ErrorModelSetResultInstance,
        result_interface: *const ErrorModelSetResultInterface,
    ) -> Errno,
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: ErrorModelInstance,
            nth_metric: u8,
            out_tag_str: *mut ffi::c_char,
            out_datatype: *mut u8,
            out_data: *mut u64,
        ) -> Errno,
    >,
}

/// Provides an error model backend that controls a plugin, in the form of a shared object.
/// The plugin must expose a struct of type [ErrorModelPluginDescriptorV1] with the symbol name
/// `selene_error_model_plugin_descriptor_v1` or a function
/// `selene_error_model_get_plugin_descriptor_v1` that returns a pointer to such a struct.
///
///
/// This interface allows implementations of behaviour to be written and distributed independently
/// of selene. Users should be cautious about the plugins they use, as it is possible that mistakes
/// or malicious code could be present in the plugin, and as with all external libraries, due
/// dilligence must be done to verify the source and the trustworthiness of the provider.
pub struct ErrorModelPluginInterface {
    _lib: libloading::Library,
    init_fn: unsafe extern "C" fn(
        handle: *mut ErrorModelInstance,
        n_qubits: u64,
        error_model_argc: u32,
        error_model_argv: *const *const ffi::c_char,
    ) -> Errno,
    exit_fn: Option<unsafe extern "C" fn(handle: ErrorModelInstance) -> Errno>,
    shot_start_fn: unsafe extern "C" fn(
        handle: ErrorModelInstance,
        shot_id: u64,
        error_model_seed: u64,
    ) -> Errno,
    shot_end_fn: unsafe extern "C" fn(handle: ErrorModelInstance) -> Errno,
    handle_operations_fn: unsafe extern "C" fn(
        handle: ErrorModelInstance,
        batch_instance: crate::runtime::plugin::RuntimeExtractOperationInstance,
        batch_interface: *const crate::runtime::plugin::RuntimeExtractOperationInterface,
        simulator_instance: crate::simulator::plugin::SimulatorInstance,
        simulator_interface: *const crate::simulator::inline::SimulatorOperationInterface,
        result_instance: ErrorModelSetResultInstance,
        result_interface: *const ErrorModelSetResultInterface,
    ) -> Errno,
    get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: ErrorModelInstance,
            nth_metric: u8,
            out_tag_str: *mut ffi::c_char,
            out_datatype: *mut u8,
            out_data: *mut u64,
        ) -> Errno,
    >,
}

impl ErrorModelPluginInterface {
    pub fn new_from_file(plugin_file: impl AsRef<OsStr>) -> Result<Arc<Self>> {
        let lib = unsafe { libloading::Library::new(plugin_file.as_ref()) }.map_err(|e| {
            anyhow!(
                "Failed to load error model plugin: {}. Error: {}",
                plugin_file.as_ref().to_string_lossy(),
                e
            )
        })?;
        let descriptor = unsafe {
            lib.get::<ErrorModelPluginDescriptorV1>(b"selene_error_model_plugin_descriptor_v1")
                .ok()
                .map(|d| *d)
                .or_else(|| {
                    lib.get::<unsafe extern "C" fn() -> *const ErrorModelPluginDescriptorV1>(
                        b"selene_error_model_get_plugin_descriptor_v1",
                    )
                    .ok()
                    .and_then(|f| {
                        let ptr = f();
                        if ptr.is_null() { None } else { Some(*ptr) }
                    })
                })
        }
        .ok_or_else(|| {
            anyhow!(
                "Error model plugin '{}' does not expose either selene_error_model_plugin_descriptor_v1 or selene_error_model_get_plugin_descriptor_v1",
                plugin_file.as_ref().to_string_lossy()
            )
        })?;
        let version: ErrorModelAPIVersion = descriptor.api_version.into();
        version.validate()?;
        if descriptor.struct_size < core::mem::size_of::<ErrorModelPluginDescriptorV1>() as u64 {
            return Err(anyhow!(
                "Error model plugin descriptor is too small for v1 ABI"
            ));
        }
        if descriptor.abi_magic != crate::PLUGIN_DESCRIPTOR_V1_MAGIC {
            return Err(anyhow!("Error model plugin descriptor has invalid magic"));
        }
        if descriptor.abi_hash != ERROR_MODEL_DESCRIPTOR_ABI_HASH {
            return Err(anyhow!(
                "Error model plugin descriptor has incompatible ABI hash"
            ));
        }
        if descriptor.abi_name.is_null() {
            return Err(anyhow!("Error model plugin descriptor ABI name is null"));
        }
        let abi_name = unsafe { std::ffi::CStr::from_ptr(descriptor.abi_name) }.to_string_lossy();
        if abi_name.as_ref() != ERROR_MODEL_DESCRIPTOR_ABI_NAME {
            return Err(anyhow!(
                "Error model plugin descriptor ABI name mismatch: {abi_name}"
            ));
        }
        if descriptor.signature_manifest.is_null() {
            return Err(anyhow!(
                "Error model plugin descriptor signature manifest is null"
            ));
        }
        let manifest =
            unsafe { std::ffi::CStr::from_ptr(descriptor.signature_manifest) }.to_string_lossy();
        if manifest.as_ref() != ERROR_MODEL_DESCRIPTOR_SIGNATURE_MANIFEST {
            return Err(anyhow!(
                "Error model plugin signature manifest mismatch.\nExpected: {}\nFound: {}",
                ERROR_MODEL_DESCRIPTOR_SIGNATURE_MANIFEST,
                manifest
            ));
        }
        Ok(Arc::new(Self {
            _lib: lib,
            init_fn: descriptor.init_fn,
            exit_fn: descriptor.exit_fn,
            shot_start_fn: descriptor.shot_start_fn,
            shot_end_fn: descriptor.shot_end_fn,
            handle_operations_fn: descriptor.handle_operations_fn,
            get_metrics_fn: descriptor.get_metrics_fn,
        }))
    }
}

impl ErrorModelInterfaceFactory for ErrorModelPluginInterface {
    type Interface = ErrorModelPlugin;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(error_model_args, |error_model_argc, error_model_argv| {
            check_errno(
                unsafe {
                    (self.init_fn)(&mut instance, n_qubits, error_model_argc, error_model_argv)
                },
                || anyhow!("ErrorModelPluginInterface: init failed"),
            )
        })?;
        Ok(Box::new(ErrorModelPlugin {
            interface: self.clone(),
            instance,
        }))
    }
}

pub struct ErrorModelPlugin {
    interface: Arc<ErrorModelPluginInterface>,
    instance: ErrorModelInstance,
}

impl ErrorModelInterface for ErrorModelPlugin {
    fn exit(&mut self) -> Result<()> {
        let Some(exit_fn) = self.interface.exit_fn else {
            return Ok(());
        };
        check_errno(unsafe { exit_fn(self.instance) }, || {
            anyhow!("ErrorModelPlugin: exit failed")
        })
    }
    fn shot_start(&mut self, shot_id: u64, error_model_seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, error_model_seed) },
            || anyhow!("ErrorModelPlugin: shot_start failed"),
        )
    }
    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            || anyhow!("ErrorModelPlugin: shot_end failed"),
        )
    }
    fn handle_operations(
        &mut self,
        operations: BatchOperation,
        simulator: &mut dyn crate::simulator::SimulatorInterface,
    ) -> Result<BatchResult> {
        let mut batch_extractor =
            crate::runtime::plugin::BatchExtractor::from_batch_operation(operations);
        let (batch_instance, batch_interface) = batch_extractor.runtime_batch_extraction();
        let mut result_builder = BatchResultBuilder::default();
        let (result_instance, result_interface) = result_builder.error_model_set_result();
        let mut simulator_ref = simulator;
        let (simulator_instance, simulator_interface) =
            crate::simulator::inline::borrowed_simulator_interface(&mut simulator_ref);
        check_errno(
            unsafe {
                (self.interface.handle_operations_fn)(
                    self.instance,
                    batch_instance,
                    &raw const batch_interface,
                    simulator_instance,
                    &raw const simulator_interface,
                    result_instance,
                    &raw const result_interface,
                )
            },
            || anyhow!("ErrorModelPlugin: handle_operations failed"),
        )?;
        Ok(result_builder.finish())
    }
    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let Some(get_metrics_fn) = self.interface.get_metrics_fn else {
            return Ok(None);
        };
        read_raw_metric(|tag, data_type, data| unsafe {
            get_metrics_fn(self.instance, nth_metric, tag, data_type, data)
        })
    }
}

#[derive(Default)]
/// A helper type used by the plugin tooling above to implement
/// [ErrorModelSetResultInterface].
struct BatchResultBuilder(BatchResult);

impl BatchResultBuilder {
    unsafe extern "C" fn set_bool_result(
        interface: ErrorModelSetResultInstance,
        result_id: u64,
        value: bool,
    ) {
        let result = interface as *mut BatchResult;
        (unsafe { &mut *result })
            .bool_results
            .push(BoolResult { result_id, value })
    }
    unsafe extern "C" fn set_u64_result(
        interface: ErrorModelSetResultInstance,
        result_id: u64,
        value: u64,
    ) {
        let result = interface as *mut BatchResult;
        (unsafe { &mut *result })
            .u64_results
            .push(U64Result { result_id, value })
    }

    /// The plugin calls this to obtain an instance and an interface.
    /// The lifetime parameter of the interface ensures that it cannot outlive the `Vec`
    /// that the functions will mutate.
    fn error_model_set_result(
        &mut self,
    ) -> (
        ErrorModelSetResultInstance,
        ErrorModelSetResultInterface<'_>,
    ) {
        let instance = &raw mut self.0 as ErrorModelSetResultInstance;
        let interface = ErrorModelSetResultInterface {
            set_bool_result_fn: Self::set_bool_result,
            set_u64_result_fn: Self::set_u64_result,
            _marker: PhantomData,
        };
        (instance, interface)
    }

    /// Consumes the `BatchBuilder` returning the accumulated operations.
    fn finish(self) -> BatchResult {
        self.0
    }
}

/// An instance is provided to `selene_runtime_get_next_operations`, which must
/// pass that back to any function it calls in it's provided
/// [ErrorModelSetResultInterface].
pub type ErrorModelSetResultInstance = *mut ffi::c_void;

#[repr(C)]
#[non_exhaustive]
/// A plugin's implementation of `selene_runtime_get_next_operations` is provided
/// a pointer to a `ErrorModelSetResultInterface` as well as a
/// [ErrorModelSetResultInstance]. It should call the functions
/// within to populate a batch. All such calls must pass the instance as the
/// first parameter.
pub struct ErrorModelSetResultInterface<'a> {
    pub set_bool_result_fn: unsafe extern "C" fn(ErrorModelSetResultInstance, u64, bool),
    pub set_u64_result_fn: unsafe extern "C" fn(ErrorModelSetResultInstance, u64, u64),
    _marker: PhantomData<&'a ()>,
}
