use super::{BatchResult, ErrorModelAPIVersion, ErrorModelInterface, ErrorModelInterfaceFactory};
use crate::gatewire::DynamicGateSet;
use crate::operation::BatchOperation;
use crate::operation::plugin::{OperationResultBuilder, OperationResultHandle};
use crate::plugin::{
    LastErrorFn, NegotiateGatesetFn, PluginDescriptorHeaderV1, PluginDescriptorV1,
    check_plugin_errno, load_descriptor_v1, load_library, negotiate_gateset, read_plugin_name,
    require_callback, validate_descriptor_v1,
};
use crate::utils::{MetricValue, read_raw_metric, with_strings_to_cargs};
use anyhow::{Result, anyhow};
use std::ffi::OsStr;
use std::{ffi, sync::Arc};

pub type ErrorModelInstance = *mut ffi::c_void;
pub type Errno = i32;

#[repr(C)]
#[derive(Clone, Copy)]
pub struct ErrorModelPluginDescriptorV1 {
    pub header: PluginDescriptorHeaderV1,
    pub init_fn: Option<
        unsafe extern "C" fn(
            handle: *mut ErrorModelInstance,
            n_qubits: u64,
            error_model_argc: u32,
            error_model_argv: *const *const ffi::c_char,
        ) -> Errno,
    >,
    pub exit_fn: Option<unsafe extern "C" fn(handle: ErrorModelInstance) -> Errno>,
    pub shot_start_fn: Option<
        unsafe extern "C" fn(
            handle: ErrorModelInstance,
            shot_id: u64,
            error_model_seed: u64,
        ) -> Errno,
    >,
    pub shot_end_fn: Option<unsafe extern "C" fn(handle: ErrorModelInstance) -> Errno>,
    pub handle_operations_fn: Option<
        unsafe extern "C" fn(
            handle: ErrorModelInstance,
            batch: crate::operation::plugin::RuntimeExtractOperationHandle,
            simulator: crate::simulator::inline::SimulatorHandle<'static>,
            result: OperationResultHandle,
        ) -> Errno,
    >,
    pub get_metrics_fn: Option<
        unsafe extern "C" fn(
            handle: ErrorModelInstance,
            nth_metric: u8,
            out_tag_str: *mut ffi::c_char,
            out_datatype: *mut u8,
            out_data: *mut u64,
        ) -> Errno,
    >,
    pub negotiate_gateset_fn: Option<
        unsafe extern "C" fn(
            handle: ErrorModelInstance,
            input: *const u8,
            input_len: usize,
            output: *mut u8,
            output_len: usize,
            written: *mut usize,
        ) -> Errno,
    >,
}

impl PluginDescriptorV1 for ErrorModelPluginDescriptorV1 {
    const KIND: &'static str = "Error model";

    fn header(&self) -> &PluginDescriptorHeaderV1 {
        &self.header
    }
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
/// diligence must be done to verify the source and the trustworthiness of the provider.
pub struct ErrorModelPluginInterface {
    _lib: libloading::Library,
    last_error_fn: LastErrorFn,
    name: String,
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
    negotiate_gateset_fn: NegotiateGatesetFn<ErrorModelInstance>,
    handle_operations_fn: unsafe extern "C" fn(
        handle: ErrorModelInstance,
        batch: crate::operation::plugin::RuntimeExtractOperationHandle,
        simulator: crate::simulator::inline::SimulatorHandle<'static>,
        result: OperationResultHandle,
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
        let lib = load_library("error model", &plugin_file)?;
        let descriptor = unsafe {
            load_descriptor_v1::<ErrorModelPluginDescriptorV1>(
                &lib,
                &plugin_file,
                b"selene_error_model_plugin_descriptor_v1",
                b"selene_error_model_get_plugin_descriptor_v1",
            )
        }?;
        validate_descriptor_v1(&descriptor, |api_version| {
            ErrorModelAPIVersion::from(api_version).validate()
        })?;
        let name = read_plugin_name("Error model", descriptor.header.get_name_fn)?;
        Ok(Arc::new(Self {
            _lib: lib,
            last_error_fn: descriptor.header.last_error_fn,
            name,
            init_fn: require_callback("Error model", "init_fn", descriptor.init_fn)?,
            exit_fn: descriptor.exit_fn,
            shot_start_fn: require_callback(
                "Error model",
                "shot_start_fn",
                descriptor.shot_start_fn,
            )?,
            shot_end_fn: require_callback("Error model", "shot_end_fn", descriptor.shot_end_fn)?,
            negotiate_gateset_fn: require_callback(
                "Error model",
                "negotiate_gateset_fn",
                descriptor.negotiate_gateset_fn,
            )?,
            handle_operations_fn: require_callback(
                "Error model",
                "handle_operations_fn",
                descriptor.handle_operations_fn,
            )?,
            get_metrics_fn: descriptor.get_metrics_fn,
        }))
    }
}

impl ErrorModelInterfaceFactory for ErrorModelPluginInterface {
    type Interface = ErrorModelPlugin;

    fn name(&self) -> &str {
        &self.name
    }

    fn init(
        self: Arc<Self>,
        n_qubits: u64,
        error_model_args: &[impl AsRef<str>],
    ) -> Result<Box<Self::Interface>> {
        let mut instance = std::ptr::null_mut();
        with_strings_to_cargs(error_model_args, |error_model_argc, error_model_argv| {
            check_plugin_errno(
                unsafe {
                    (self.init_fn)(&mut instance, n_qubits, error_model_argc, error_model_argv)
                },
                self.last_error_fn,
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
        check_plugin_errno(
            unsafe { exit_fn(self.instance) },
            self.interface.last_error_fn,
            || anyhow!("ErrorModelPlugin: exit failed"),
        )
    }
    fn shot_start(&mut self, shot_id: u64, error_model_seed: u64) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.shot_start_fn)(self.instance, shot_id, error_model_seed) },
            self.interface.last_error_fn,
            || anyhow!("ErrorModelPlugin: shot_start failed"),
        )
    }
    fn shot_end(&mut self) -> Result<()> {
        check_plugin_errno(
            unsafe { (self.interface.shot_end_fn)(self.instance) },
            self.interface.last_error_fn,
            || anyhow!("ErrorModelPlugin: shot_end failed"),
        )
    }

    fn negotiate_gateset(&mut self, gateset: &DynamicGateSet) -> Result<DynamicGateSet> {
        negotiate_gateset(
            "ErrorModelPlugin",
            self.instance,
            self.interface.negotiate_gateset_fn,
            self.interface.last_error_fn,
            gateset,
        )
    }
    fn handle_operations(
        &mut self,
        operations: BatchOperation,
        simulator: &mut dyn crate::simulator::SimulatorInterface,
    ) -> Result<BatchResult> {
        let mut batch_extractor =
            crate::operation::plugin::BatchExtractor::from_batch_operation(operations);
        let batch = batch_extractor.runtime_batch_extraction();
        let mut result_builder = OperationResultBuilder::default();
        let result = result_builder.operation_result();
        let mut simulator_ref = simulator;
        let simulator = crate::simulator::inline::borrowed_simulator_interface(&mut simulator_ref)
            .into_static();
        check_plugin_errno(
            unsafe {
                (self.interface.handle_operations_fn)(self.instance, batch, simulator, result)
            },
            self.interface.last_error_fn,
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
