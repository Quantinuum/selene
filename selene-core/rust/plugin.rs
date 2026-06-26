use anyhow::{Result, anyhow, bail};
use libloading::Library;
use std::ffi::OsStr;

use crate::gatewire::DynamicGateSet;
use crate::utils::check_errno;

pub type Errno = i32;

pub(crate) trait PluginDescriptorV1: Copy {
    const KIND: &'static str;

    fn struct_size(&self) -> u64;
    fn api_version(&self) -> u64;
}

pub(crate) fn load_library(kind: &str, plugin_file: &impl AsRef<OsStr>) -> Result<Library> {
    unsafe { Library::new(plugin_file.as_ref()) }.map_err(|error| {
        anyhow!(
            "Failed to load {} plugin: {}. Error: {}",
            kind,
            plugin_file.as_ref().to_string_lossy(),
            error
        )
    })
}

pub(crate) unsafe fn load_descriptor_v1<T: PluginDescriptorV1>(
    lib: &Library,
    plugin_file: &impl AsRef<OsStr>,
    descriptor_symbol: &'static [u8],
    getter_symbol: &'static [u8],
) -> Result<T> {
    let descriptor = unsafe {
        lib.get::<T>(descriptor_symbol)
            .ok()
            .map(|descriptor| *descriptor)
            .or_else(|| {
                lib.get::<unsafe extern "C" fn() -> *const T>(getter_symbol)
                    .ok()
                    .and_then(|get_descriptor| {
                        let ptr = get_descriptor();
                        if ptr.is_null() { None } else { Some(*ptr) }
                    })
            })
    };

    descriptor.ok_or_else(|| {
        anyhow!(
            "{} plugin '{}' does not expose either {} or {}",
            T::KIND,
            plugin_file.as_ref().to_string_lossy(),
            String::from_utf8_lossy(descriptor_symbol),
            String::from_utf8_lossy(getter_symbol),
        )
    })
}

pub(crate) fn validate_descriptor_v1<T: PluginDescriptorV1>(
    descriptor: &T,
    validate_api_version: impl FnOnce(u64) -> Result<()>,
) -> Result<()> {
    validate_api_version(descriptor.api_version())?;
    if descriptor.struct_size() < core::mem::size_of::<T>() as u64 {
        return Err(anyhow!(
            "{} plugin descriptor is too small for v1 ABI",
            T::KIND
        ));
    }
    Ok(())
}

pub(crate) fn require_callback<T>(
    kind: &str,
    callback_name: &str,
    callback: Option<T>,
) -> Result<T> {
    callback.ok_or_else(|| {
        anyhow!("{kind} plugin descriptor is missing required callback {callback_name}")
    })
}

pub(crate) type NegotiateGatesetFn<I> = unsafe extern "C" fn(
    handle: I,
    input: *const u8,
    input_len: usize,
    output: *mut u8,
    output_len: usize,
    written: *mut usize,
) -> Errno;

pub(crate) fn negotiate_gateset<I: Copy>(
    kind: &str,
    instance: I,
    negotiate_gateset_fn: Option<NegotiateGatesetFn<I>>,
    gateset: &DynamicGateSet,
) -> Result<DynamicGateSet> {
    let Some(negotiate_gateset_fn) = negotiate_gateset_fn else {
        return Ok(gateset.clone());
    };

    let input = gateset.serialize();
    let mut written = 0usize;
    check_errno(
        unsafe {
            negotiate_gateset_fn(
                instance,
                input.as_ptr(),
                input.len(),
                std::ptr::null_mut(),
                0,
                &mut written,
            )
        },
        || anyhow!("{kind}: negotiate_gateset failed"),
    )?;

    let mut output = vec![0u8; written];
    check_errno(
        unsafe {
            negotiate_gateset_fn(
                instance,
                input.as_ptr(),
                input.len(),
                output.as_mut_ptr(),
                output.len(),
                &mut written,
            )
        },
        || anyhow!("{kind}: negotiate_gateset failed"),
    )?;

    output.truncate(written);
    Ok(DynamicGateSet::deserialize(&output)?)
}

pub(crate) unsafe fn write_negotiated_gateset(
    input: *const u8,
    input_len: usize,
    output: *mut u8,
    output_len: usize,
    written: *mut usize,
    negotiate: impl FnOnce(&DynamicGateSet) -> Result<DynamicGateSet>,
) -> Result<()> {
    if written.is_null() {
        bail!("written pointer is null");
    }
    let input = if input_len == 0 {
        &[]
    } else {
        if input.is_null() {
            bail!("input pointer is null");
        }
        unsafe { std::slice::from_raw_parts(input, input_len) }
    };
    let incoming = DynamicGateSet::deserialize(input)?;
    let outgoing = negotiate(&incoming)?;
    let bytes = outgoing.serialize();
    unsafe {
        *written = bytes.len();
    }
    if output.is_null() {
        return Ok(());
    }
    if output_len < bytes.len() {
        bail!("output buffer is too small");
    }
    unsafe {
        std::ptr::copy_nonoverlapping(bytes.as_ptr(), output, bytes.len());
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::gatewire::builtin;

    #[derive(Clone, Copy)]
    struct TestDescriptor {
        struct_size: u64,
        api_version: u64,
    }

    impl PluginDescriptorV1 for TestDescriptor {
        const KIND: &'static str = "Test";

        fn struct_size(&self) -> u64 {
            self.struct_size
        }

        fn api_version(&self) -> u64 {
            self.api_version
        }
    }

    #[test]
    fn descriptor_validation_checks_version_and_size() {
        let descriptor = TestDescriptor {
            struct_size: core::mem::size_of::<TestDescriptor>() as u64,
            api_version: 7,
        };
        validate_descriptor_v1(&descriptor, |version| {
            assert_eq!(version, 7);
            Ok(())
        })
        .unwrap();

        let descriptor = TestDescriptor {
            struct_size: 0,
            api_version: 7,
        };
        let error = validate_descriptor_v1(&descriptor, |_| Ok(())).unwrap_err();
        assert!(
            error
                .to_string()
                .contains("Test plugin descriptor is too small")
        );

        let descriptor = TestDescriptor {
            struct_size: core::mem::size_of::<TestDescriptor>() as u64,
            api_version: 7,
        };
        let error =
            validate_descriptor_v1(&descriptor, |_| Err(anyhow!("bad version"))).unwrap_err();
        assert_eq!(error.to_string(), "bad version");
    }

    #[test]
    fn required_callback_validation_names_missing_callback() {
        let error = require_callback::<fn()>("Test", "init_fn", None).unwrap_err();
        assert_eq!(
            error.to_string(),
            "Test plugin descriptor is missing required callback init_fn"
        );

        let callback = require_callback("Test", "init_fn", Some(|| {})).unwrap();
        callback();
    }

    unsafe extern "C" fn echo_gateset(
        _handle: usize,
        input: *const u8,
        input_len: usize,
        output: *mut u8,
        output_len: usize,
        written: *mut usize,
    ) -> Errno {
        unsafe {
            *written = input_len;
            if output.is_null() {
                return 0;
            }
            if output_len < input_len {
                return -1;
            }
            std::ptr::copy_nonoverlapping(input, output, input_len);
        }
        0
    }

    #[test]
    fn negotiate_gateset_uses_two_call_output_protocol() {
        let gateset = builtin::all();
        let negotiated =
            negotiate_gateset("TestPlugin", 0usize, Some(echo_gateset), &gateset).unwrap();
        assert_eq!(negotiated.serialize(), gateset.serialize());
    }

    #[test]
    fn negotiate_gateset_defaults_to_input_when_callback_is_absent() {
        let gateset = builtin::all();
        let negotiated = negotiate_gateset::<usize>("TestPlugin", 0usize, None, &gateset).unwrap();
        assert_eq!(negotiated.serialize(), gateset.serialize());
    }

    #[test]
    fn write_negotiated_gateset_validates_null_pointers() {
        let gateset = builtin::all();
        let data = gateset.serialize();
        let mut written = 0usize;

        let error = unsafe {
            write_negotiated_gateset(
                data.as_ptr(),
                data.len(),
                std::ptr::null_mut(),
                0,
                std::ptr::null_mut(),
                |incoming| Ok(incoming.clone()),
            )
        }
        .unwrap_err();
        assert_eq!(error.to_string(), "written pointer is null");

        let error = unsafe {
            write_negotiated_gateset(
                std::ptr::null(),
                data.len(),
                std::ptr::null_mut(),
                0,
                &mut written,
                |incoming| Ok(incoming.clone()),
            )
        }
        .unwrap_err();
        assert_eq!(error.to_string(), "input pointer is null");
    }
}
