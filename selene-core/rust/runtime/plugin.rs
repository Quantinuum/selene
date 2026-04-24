use crate::runtime::Operation;
use crate::utils::{MetricValue, check_errno, read_raw_metric, with_strings_to_cargs};

use super::{BatchOperation, RuntimeAPIVersion, RuntimeInterface, RuntimeInterfaceFactory};
use anyhow::{Result, anyhow};
use core::slice;
use libloading;
use std::ffi::OsStr;
use std::marker::PhantomData;
use std::{ffi, sync::Arc};

pub type RuntimeInstance = *mut ffi::c_void;

pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RuntimePluginDescriptorV1 {
    pub struct_size: u64,
    pub api_version: u64,
    pub init_fn: unsafe extern "C" fn(
        handle: *mut RuntimeInstance,
        n_qubits: u64,
        start: u64,
        argc: u32,
        argv: *const *const ffi::c_char,
    ) -> Errno,
    pub exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    pub get_next_operations_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        instance: RuntimeGetOperationInstance,
        interface: *const RuntimeGetOperationInterface,
    ) -> Errno,
    pub shot_start_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, shot_id: u64, seed: u64) -> Errno,
    pub shot_end_fn: unsafe extern "C" fn(handle: RuntimeInstance) -> Errno,
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            nth_metric: u8,
            tag_out: *mut ffi::c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> i32,
    >,
    pub qalloc_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress_out: *mut u64) -> Errno,
    pub qfree_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress: u64) -> Errno,
    pub local_barrier_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubits: *const u64,
        qubits_len: u64,
        sleep_ns: u64,
    ) -> Errno,
    pub global_barrier_fn: unsafe extern "C" fn(handle: RuntimeInstance, sleep_ns: u64) -> Errno,
    pub rxy_gate_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64, phi: f64) -> Errno,
    pub rzz_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
    ) -> Errno,
    pub rz_gate_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64) -> Errno,
    pub tk2_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) -> Errno,
    pub rpp_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
        phi: f64,
    ) -> Errno,
    pub measure_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    pub measure_leaked_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    pub reset_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64) -> Errno,
    pub force_result_fn: unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    pub get_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut i8) -> Errno,
    pub get_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut u64) -> Errno,
    pub set_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: bool) -> Errno,
    pub set_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: u64) -> Errno,
    pub increment_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    pub decrement_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    pub custom_call_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            tag: u64,
            data: *const ffi::c_void,
            data_len: usize,
            result: *mut u64,
        ) -> Errno,
    >,
    pub simulate_delay_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, delay_ns: u64) -> Errno>,
}

/// Provides a runtime engine backend that controls a plugin, in the form of a shared object.
/// The plugin must expose a struct of type [RuntimePluginDescriptorV1], either as a symbol named
/// `selene_runtime_plugin_descriptor_v1` or as a pointer returned by a function named
/// `selene_runtime_get_plugin_descriptor_v1`.
///
/// Users should be cautious about the plugins they use, as it is possible that mistakes
/// or malicious code could be present in the plugin, and as with all external libraries, due
/// dilligence must be done to verify the source and the trustworthiness of the provider.
pub struct RuntimePluginInterface {
    _lib: libloading::Library,
    init_fn: unsafe extern "C" fn(
        handle: *mut RuntimeInstance,
        n_qubits: u64,
        start: u64,
        argc: u32,
        argv: *const *const ffi::c_char,
    ) -> Errno,
    exit_fn: Option<unsafe extern "C" fn(handle: RuntimeInstance) -> Errno>,
    get_next_operations_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        instance: RuntimeGetOperationInstance,
        interface: *const RuntimeGetOperationInterface,
    ) -> Errno,
    shot_start_fn: unsafe extern "C" fn(handle: RuntimeInstance, shot_id: u64, seed: u64) -> Errno,
    shot_end_fn: unsafe extern "C" fn(handle: RuntimeInstance) -> Errno,
    get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            nth_metric: u8,
            tag_out: *mut ffi::c_char,
            datatype_out: *mut u8,
            value_out: *mut u64,
        ) -> i32,
    >,
    qalloc_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress_out: *mut u64) -> Errno,
    qfree_fn: unsafe extern "C" fn(handle: RuntimeInstance, qaddress: u64) -> Errno,
    local_barrier_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubits: *const u64,
        qubits_len: u64,
        sleep_ns: u64,
    ) -> Errno,
    global_barrier_fn: unsafe extern "C" fn(handle: RuntimeInstance, sleep_ns: u64) -> Errno,
    rxy_gate_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64, phi: f64) -> Errno,
    rzz_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
    ) -> Errno,
    rz_gate_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, theta: f64) -> Errno,
    tk2_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) -> Errno,
    rpp_gate_fn: unsafe extern "C" fn(
        handle: RuntimeInstance,
        qubit0: u64,
        qubit1: u64,
        theta: f64,
        phi: f64,
    ) -> Errno,
    measure_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    measure_leaked_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64, result_id: *mut u64) -> Errno,
    reset_fn: unsafe extern "C" fn(handle: RuntimeInstance, qubit: u64) -> Errno,
    force_result_fn: unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    get_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut i8) -> Errno,
    get_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, id: u64, result: *mut u64) -> Errno,
    set_bool_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: bool) -> Errno,
    set_u64_result_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64, result: u64) -> Errno,
    increment_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    decrement_future_refcount_fn:
        unsafe extern "C" fn(handle: RuntimeInstance, result_id: u64) -> Errno,
    custom_call_fn: Option<
        unsafe extern "C" fn(
            handle: RuntimeInstance,
            tag: u64,
            data: *const ffi::c_void,
            data_len: usize,
            result: *mut u64,
        ) -> Errno,
    >,
    simulate_delay_fn:
        Option<unsafe extern "C" fn(handle: RuntimeInstance, delay_ns: u64) -> Errno>,
}

impl RuntimePluginInterface {
    /// Loads a runtime plugin from a file.
    pub fn new_from_file(plugin_file: impl AsRef<OsStr>) -> Result<Arc<Self>> {
        let lib = unsafe { libloading::Library::new(plugin_file.as_ref()) }.map_err(|e| {
            anyhow!(
                "Failed to load runtime plugin: {}. Error: {}",
                plugin_file.as_ref().to_string_lossy(),
                e
            )
        })?;
        let descriptor = unsafe {
            lib.get::<RuntimePluginDescriptorV1>(b"selene_runtime_plugin_descriptor_v1")
                .ok()
                .map(|d| *d)
                .or_else(|| {
                    lib.get::<unsafe extern "C" fn() -> *const RuntimePluginDescriptorV1>(
                        b"selene_runtime_get_plugin_descriptor_v1",
                    )
                    .ok()
                    .and_then(|f| {
                        let ptr = f();
                        if ptr.is_null() { None } else { Some(*ptr) }
                    })
                })
        };
        let descriptor = descriptor.ok_or_else(|| {
            anyhow!(
                "Runtime plugin '{}' does not expose either selene_runtime_plugin_descriptor_v1 or selene_runtime_get_plugin_descriptor_v1",
                plugin_file.as_ref().to_string_lossy()
            )
        })?;
        let version: RuntimeAPIVersion = descriptor.api_version.into();
        version.validate()?;
        if descriptor.struct_size < core::mem::size_of::<RuntimePluginDescriptorV1>() as u64 {
            return Err(anyhow!("Runtime plugin descriptor is too small for v1 ABI"));
        }
        Ok(Arc::new(Self {
            _lib: lib,
            init_fn: descriptor.init_fn,
            exit_fn: descriptor.exit_fn,
            get_next_operations_fn: descriptor.get_next_operations_fn,
            shot_start_fn: descriptor.shot_start_fn,
            shot_end_fn: descriptor.shot_end_fn,
            get_metrics_fn: descriptor.get_metrics_fn,
            qalloc_fn: descriptor.qalloc_fn,
            qfree_fn: descriptor.qfree_fn,
            local_barrier_fn: descriptor.local_barrier_fn,
            global_barrier_fn: descriptor.global_barrier_fn,
            rxy_gate_fn: descriptor.rxy_gate_fn,
            rzz_gate_fn: descriptor.rzz_gate_fn,
            rz_gate_fn: descriptor.rz_gate_fn,
            tk2_gate_fn: descriptor.tk2_gate_fn,
            rpp_gate_fn: descriptor.rpp_gate_fn,
            measure_fn: descriptor.measure_fn,
            measure_leaked_fn: descriptor.measure_leaked_fn,
            reset_fn: descriptor.reset_fn,
            force_result_fn: descriptor.force_result_fn,
            get_bool_result_fn: descriptor.get_bool_result_fn,
            get_u64_result_fn: descriptor.get_u64_result_fn,
            set_bool_result_fn: descriptor.set_bool_result_fn,
            set_u64_result_fn: descriptor.set_u64_result_fn,
            increment_future_refcount_fn: descriptor.increment_future_refcount_fn,
            decrement_future_refcount_fn: descriptor.decrement_future_refcount_fn,
            custom_call_fn: descriptor.custom_call_fn,
            simulate_delay_fn: descriptor.simulate_delay_fn,
        }))
    }
}

impl RuntimeInterfaceFactory for RuntimePluginInterface {
    type Interface = RuntimePlugin;

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        start: crate::time::Instant,
        args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(args, |argc, argv| {
            check_errno(
                unsafe { (self.init_fn)(&mut instance, n_qubits, start.into(), argc, argv) },
                || anyhow!("RuntimePluginInterface: init failed"),
            )
        })?;
        Ok(Box::new(RuntimePlugin {
            interface: self.clone(),
            instance,
        }))
    }
}

pub struct RuntimePlugin {
    interface: Arc<RuntimePluginInterface>,
    instance: RuntimeInstance,
}

impl RuntimeInterface for RuntimePlugin {
    fn exit(&mut self) -> Result<()> {
        let Some(exit_fn) = self.interface.exit_fn else {
            return Ok(());
        };
        check_errno(unsafe { exit_fn(self.instance) }, || {
            anyhow!("RuntimePlugin: exit failed")
        })
    }

    fn get_next_operations(&mut self) -> Result<Option<BatchOperation>> {
        let mut batch_builder = BatchBuilder::default();
        let (instance, interface) = batch_builder.runtime_get_operation();
        check_errno(
            unsafe {
                (self.interface.get_next_operations_fn)(
                    self.instance,
                    instance,
                    &raw const interface,
                )
            },
            || anyhow!("RuntimePlugin: get_next_operations failed"),
        )?;
        Ok(Some(batch_builder.finish()).filter(|b| !b.is_empty()))
    }

    fn shot_start(&mut self, shot_id: u64, seed: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, seed) },
            || anyhow!("RuntimePlugin: shot_start failed"),
        )
    }

    fn shot_end(&mut self) -> Result<()> {
        check_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            || anyhow!("RuntimePlugin: shot_end failed"),
        )
    }

    fn get_metric(&mut self, nth_metric: u8) -> Result<Option<(String, MetricValue)>> {
        let Some(get_metrics_fn) = self.interface.get_metrics_fn else {
            return Ok(None);
        };
        read_raw_metric(|tag, data_type, data| unsafe {
            get_metrics_fn(self.instance, nth_metric, tag, data_type, data)
        })
    }

    fn qalloc(&mut self) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.interface.qalloc_fn)(self.instance, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: qalloc failed"),
        )?;
        Ok(result)
    }

    fn qfree(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.qfree_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: qfree failed"),
        )
    }

    fn global_barrier(&mut self, sleep_ns: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.global_barrier_fn)(self.instance, sleep_ns) },
            || anyhow!("RuntimePlugin: global barrier failed"),
        )
    }

    fn local_barrier(&mut self, qubit_ids: &[u64], sleep_ns: u64) -> Result<()> {
        let qubit_ids_len = qubit_ids.len() as u64;
        let qubit_ids_ptr = qubit_ids.as_ptr();
        check_errno(
            unsafe {
                (self.interface.local_barrier_fn)(
                    self.instance,
                    qubit_ids_ptr,
                    qubit_ids_len,
                    sleep_ns,
                )
            },
            || anyhow!("RuntimePlugin: local barrier failed"),
        )
    }

    fn rxy_gate(&mut self, qubit_id: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rxy_gate_fn)(self.instance, qubit_id, theta, phi) },
            || anyhow!("RuntimePlugin: rxy_gate failed"),
        )
    }

    fn rzz_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rzz_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta) },
            || anyhow!("RuntimePlugin: rzz_gate failed"),
        )
    }

    fn rz_gate(&mut self, qubit_id: u64, theta: f64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.rz_gate_fn)(self.instance, qubit_id, theta) },
            || anyhow!("RuntimePlugin: rz_gate failed"),
        )
    }

    fn rpp_gate(&mut self, qubit_id_1: u64, qubit_id_2: u64, theta: f64, phi: f64) -> Result<()> {
        check_errno(
            unsafe {
                (self.interface.rpp_gate_fn)(self.instance, qubit_id_1, qubit_id_2, theta, phi)
            },
            || anyhow!("RuntimePlugin: rpp_gate failed"),
        )
    }

    fn tk2_gate(
        &mut self,
        qubit_id_1: u64,
        qubit_id_2: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) -> Result<()> {
        check_errno(
            unsafe {
                (self.interface.tk2_gate_fn)(
                    self.instance,
                    qubit_id_1,
                    qubit_id_2,
                    alpha,
                    beta,
                    gamma,
                )
            },
            || anyhow!("RuntimePlugin: tk2_gate failed"),
        )
    }

    fn measure(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe { (self.interface.measure_fn)(self.instance, qubit_id, result_ref as *mut _) },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn measure_leaked(&mut self, qubit_id: u64) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.interface.measure_leaked_fn)(self.instance, qubit_id, result_ref as *mut _)
            },
            || anyhow!("RuntimePlugin: measure failed"),
        )?;
        Ok(result)
    }

    fn reset(&mut self, qubit_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.reset_fn)(self.instance, qubit_id) },
            || anyhow!("RuntimePlugin: reset failed"),
        )
    }

    fn force_result(&mut self, result_id: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.force_result_fn)(self.instance, result_id) },
            || anyhow!("RuntimePlugin: force_result failed"),
        )
    }

    fn get_bool_result(&mut self, result_id: u64) -> Result<Option<bool>> {
        let mut result = 0i8;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.interface.get_bool_result_fn)(self.instance, result_id, result_ref as *mut _)
            },
            || anyhow!("RuntimePlugin: get_bool_result failed"),
        )?;
        // TODO document this
        Ok(match result {
            0 => Some(false),
            1 => Some(true),
            _ => None,
        })
    }

    fn get_u64_result(&mut self, result_id: u64) -> Result<Option<u64>> {
        let mut result = 0u64;
        let result_ref = &mut result;
        check_errno(
            unsafe {
                (self.interface.get_u64_result_fn)(self.instance, result_id, result_ref as *mut u64)
            },
            || anyhow!("RuntimePlugin: get_u64_result failed"),
        )?;
        // TODO document this
        Ok(match result {
            u64::MAX => None,
            n => Some(n),
        })
    }

    fn set_bool_result(&mut self, result_id: u64, result: bool) -> Result<()> {
        check_errno(
            unsafe { (self.interface.set_bool_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_bool_result failed"),
        )
    }

    fn set_u64_result(&mut self, result_id: u64, result: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.set_u64_result_fn)(self.instance, result_id, result) },
            || anyhow!("RuntimePlugin: set_u64_result failed"),
        )
    }

    fn increment_future_refcount(&mut self, future_ref: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.increment_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: increment_future_refcount failed"),
        )
    }

    fn decrement_future_refcount(&mut self, future_ref: u64) -> Result<()> {
        check_errno(
            unsafe { (self.interface.decrement_future_refcount_fn)(self.instance, future_ref) },
            || anyhow!("RuntimePlugin: decrement_future_refcount failed"),
        )
    }

    fn custom_call(&mut self, custom_tag: u64, data: &[u8]) -> Result<u64> {
        let mut result = 0;
        let result_ref = &mut result;
        if let Some(custom_call_fn) = self.interface.custom_call_fn {
            check_errno(
                unsafe {
                    custom_call_fn(
                        self.instance,
                        custom_tag,
                        data.as_ptr() as *const ffi::c_void,
                        data.len(),
                        result_ref as *mut _,
                    )
                },
                || anyhow!("RuntimePlugin: custom_call failed"),
            )?;
            Ok(result)
        } else {
            Err(anyhow!(
                "RuntimePlugin: custom_call not supported by plugin"
            ))
        }
    }

    fn simulate_delay(&mut self, delay_ns: u64) -> Result<()> {
        if let Some(simulate_delay_fn) = self.interface.simulate_delay_fn {
            check_errno(
                unsafe { simulate_delay_fn(self.instance, delay_ns) },
                || anyhow!("RuntimePlugin: simulate_delay failed"),
            )
        } else {
            Err(anyhow!(
                "RuntimePlugin: simulate_delay not supported by plugin"
            ))
        }
    }
}

/// A helper type used by the plugin tooling above to implement
/// [RuntimeGetOperationInterface].
#[derive(Default)]
pub struct BatchBuilder(Vec<Operation>, crate::time::Instant, crate::time::Duration);

impl BatchBuilder {
    // pub fn new() -> Self {
    //     Self(None)
    // }

    fn push(interface: RuntimeGetOperationInstance, op: Operation) {
        Self::with_interface(interface, move |this| this.0.push(op))
    }

    fn with_interface<T>(
        interface: RuntimeGetOperationInstance,
        go: impl FnOnce(&mut Self) -> T,
    ) -> T {
        let this = interface as *mut Self;
        let this = unsafe { &mut *this };
        go(this)
    }

    unsafe extern "C" fn rzz(
        interface: RuntimeGetOperationInstance,
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
    ) {
        Self::push(
            interface,
            Operation::RZZGate {
                qubit_id_1,
                qubit_id_2,
                theta,
            },
        )
    }

    unsafe extern "C" fn rz(interface: RuntimeGetOperationInstance, qubit_id: u64, theta: f64) {
        Self::push(interface, Operation::RZGate { qubit_id, theta })
    }

    unsafe extern "C" fn rxy(
        interface: RuntimeGetOperationInstance,
        qubit_id: u64,
        theta: f64,
        phi: f64,
    ) {
        Self::push(
            interface,
            Operation::RXYGate {
                qubit_id,
                theta,
                phi,
            },
        )
    }

    unsafe extern "C" fn rpp(
        interface: RuntimeGetOperationInstance,
        qubit_id_1: u64,
        qubit_id_2: u64,
        theta: f64,
        phi: f64,
    ) {
        Self::push(
            interface,
            Operation::RPPGate {
                qubit_id_1,
                qubit_id_2,
                theta,
                phi,
            },
        )
    }

    unsafe extern "C" fn tk2(
        interface: RuntimeGetOperationInstance,
        qubit_id_1: u64,
        qubit_id_2: u64,
        alpha: f64,
        beta: f64,
        gamma: f64,
    ) {
        Self::push(
            interface,
            Operation::TK2Gate {
                qubit_id_1,
                qubit_id_2,
                alpha,
                beta,
                gamma,
            },
        )
    }

    unsafe extern "C" fn measure(
        interface: RuntimeGetOperationInstance,
        qubit_id: u64,
        result_id: u64,
    ) {
        Self::push(
            interface,
            Operation::Measure {
                qubit_id,
                result_id,
            },
        )
    }

    unsafe extern "C" fn measure_leaked(
        interface: RuntimeGetOperationInstance,
        qubit_id: u64,
        result_id: u64,
    ) {
        Self::push(
            interface,
            Operation::MeasureLeaked {
                qubit_id,
                result_id,
            },
        )
    }

    unsafe extern "C" fn reset(interface: RuntimeGetOperationInstance, qubit_id: u64) {
        Self::push(interface, Operation::Reset { qubit_id })
    }

    unsafe extern "C" fn custom(
        interface: RuntimeGetOperationInstance,
        custom_tag: usize,
        data: *const ffi::c_void,
        len: usize,
    ) {
        let data = unsafe { slice::from_raw_parts(data as *mut u8, len) }
            .to_vec()
            .into_boxed_slice();
        Self::push(interface, Operation::Custom { custom_tag, data })
    }

    unsafe extern "C" fn set_batch_time(
        interface: RuntimeGetOperationInstance,
        start: u64,
        duration: u64,
    ) {
        Self::with_interface(interface, |this| {
            this.1 = start.into();
            this.2 = duration.into();
        })
    }

    /// The plugin calls this to obtain an instance and an interface.
    /// The lifetime parameter of the interface ensures that it cannot outlive the `Vec`
    /// that the functions will mutate.
    pub fn runtime_get_operation(
        &mut self,
    ) -> (
        RuntimeGetOperationInstance,
        RuntimeGetOperationInterface<'_>,
    ) {
        let instance = &raw mut self.0 as RuntimeGetOperationInstance;
        let interface = RuntimeGetOperationInterface {
            measure_fn: Self::measure,
            measure_leaked_fn: Self::measure_leaked,
            reset_fn: Self::reset,
            custom_fn: Self::custom,
            set_batch_time_fn: Self::set_batch_time,
            rzz_fn: Self::rzz,
            rxy_fn: Self::rxy,
            rz_fn: Self::rz,
            rpp_fn: Self::rpp,
            tk2_fn: Self::tk2,
            _marker: PhantomData,
        };
        (instance, interface)
    }

    /// Consumes the `BatchBuilder` returning the accumulated operations.
    pub fn finish(self) -> BatchOperation {
        BatchOperation {
            ops: self.0,
            start: self.1,
            duration: self.2,
        }
    }
}

/// An instance is provided to `selene_runtime_get_next_operations`, which must
/// pass that back to any function it calls in it's provided
/// [RuntimeGetOperationInterface].
pub type RuntimeGetOperationInstance = *mut ffi::c_void;

#[repr(C)]
#[non_exhaustive]
/// A plugin's implementation of `selene_runtime_get_next_operations` is provided
/// a pointer to a `RuntimeGetOperationInterface` as well as a
/// [RuntimeGetOperationInstance]. It should call the functions
/// within to populate a batch. All such calls must pass the instance as the
/// first parameter.
pub struct RuntimeGetOperationInterface<'a> {
    pub measure_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64),
    pub measure_leaked_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64),
    pub reset_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64),
    pub custom_fn:
        unsafe extern "C" fn(RuntimeGetOperationInstance, usize, *const ffi::c_void, usize),
    pub set_batch_time_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64),
    pub rzz_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64, f64),
    pub rxy_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, f64, f64),
    pub rz_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, f64),
    pub rpp_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64, f64, f64),
    pub tk2_fn: unsafe extern "C" fn(RuntimeGetOperationInstance, u64, u64, f64, f64, f64),
    _marker: PhantomData<&'a ()>,
}

#[derive(Default)]
pub struct BatchExtractor(BatchOperation);

impl BatchExtractor {
    pub fn from_batch_operation(batch: BatchOperation) -> Self {
        Self(batch)
    }
    pub unsafe extern "C" fn extract(
        instance_in: RuntimeExtractOperationInstance,
        instance_out: RuntimeGetOperationInstance,
        interface_out: RuntimeGetOperationInterface,
    ) {
        let batch_ptr = instance_in as *const BatchOperation;
        let batch: &BatchOperation = unsafe { &*batch_ptr };
        let RuntimeGetOperationInterface {
            measure_fn,
            measure_leaked_fn,
            reset_fn,
            custom_fn,
            set_batch_time_fn,
            rzz_fn,
            rxy_fn,
            rz_fn,
            rpp_fn,
            tk2_fn,
            ..
        } = interface_out;
        unsafe { set_batch_time_fn(instance_out, batch.start().into(), batch.duration().into()) };
        for operation in batch.iter_ops() {
            match operation {
                Operation::Measure {
                    qubit_id,
                    result_id,
                } => unsafe { measure_fn(instance_out, *qubit_id, *result_id) },
                Operation::MeasureLeaked {
                    qubit_id,
                    result_id,
                } => unsafe { measure_leaked_fn(instance_out, *qubit_id, *result_id) },
                Operation::Reset { qubit_id } => unsafe { reset_fn(instance_out, *qubit_id) },
                Operation::RXYGate {
                    qubit_id,
                    theta,
                    phi,
                } => unsafe { rxy_fn(instance_out, *qubit_id, *theta, *phi) },
                Operation::RZGate { qubit_id, theta } => unsafe {
                    rz_fn(instance_out, *qubit_id, *theta)
                },
                Operation::RZZGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                } => unsafe { rzz_fn(instance_out, *qubit_id_1, *qubit_id_2, *theta) },
                Operation::RPPGate {
                    qubit_id_1,
                    qubit_id_2,
                    theta,
                    phi,
                } => unsafe { rpp_fn(instance_out, *qubit_id_1, *qubit_id_2, *theta, *phi) },
                Operation::TK2Gate {
                    qubit_id_1,
                    qubit_id_2,
                    alpha,
                    beta,
                    gamma,
                } => unsafe {
                    tk2_fn(
                        instance_out,
                        *qubit_id_1,
                        *qubit_id_2,
                        *alpha,
                        *beta,
                        *gamma,
                    )
                },
                Operation::Custom { custom_tag, data } => {
                    let (ptr, len) = (data.as_ptr() as *const ffi::c_void, data.len());
                    unsafe { custom_fn(instance_out, *custom_tag, ptr, len) }
                }
            }
        }
    }
    pub fn runtime_batch_extraction(
        &mut self,
    ) -> (
        RuntimeExtractOperationInstance,
        RuntimeExtractOperationInterface<'_>,
    ) {
        let instance = &raw mut self.0 as RuntimeExtractOperationInstance;
        let reoi = RuntimeExtractOperationInterface {
            extract_fn: Self::extract,
            _marker: PhantomData,
        };
        (instance, reoi)
    }
}

pub type RuntimeExtractOperationInstance = *mut ffi::c_void;
#[repr(C)]
#[non_exhaustive]
pub struct RuntimeExtractOperationInterface<'a> {
    pub extract_fn: unsafe extern "C" fn(
        RuntimeExtractOperationInstance,
        RuntimeGetOperationInstance,
        RuntimeGetOperationInterface,
    ),
    _marker: PhantomData<&'a ()>,
}
