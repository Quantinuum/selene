use std::path::PathBuf;

pub struct Module {
    pub path: PathBuf,
    pub base: u64,
}

#[cfg(unix)]
impl Module {
    pub fn from_program_counter(pc: u64) -> Option<Self> {
        use std::ffi::{CStr, c_void};
        use std::os::unix::ffi::OsStrExt;

        unsafe {
            let mut info: libc::Dl_info = std::mem::zeroed();

            if libc::dladdr(pc as *const c_void, &mut info) == 0 {
                return None;
            }

            if info.dli_fname.is_null() || info.dli_fbase.is_null() {
                return None;
            }

            let path = CStr::from_ptr(info.dli_fname).to_bytes();

            Some(Self {
                path: PathBuf::from(std::ffi::OsStr::from_bytes(path)),
                base: info.dli_fbase as u64,
            })
        }
    }
}

#[cfg(windows)]
impl Module {
    pub fn from_program_counter(pc: u64) -> Option<Self> {
        use std::os::windows::ffi::OsStringExt;
        use windows_sys::Win32::System::LibraryLoader::{
            FreeLibrary, GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, GetModuleFileNameW,
            GetModuleHandleExW,
        };

        unsafe {
            let mut module = std::ptr::null_mut();

            if GetModuleHandleExW(
                GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
                pc as usize as *const u16,
                &mut module,
            ) == 0
            {
                return None;
            }

            let base = module as usize as u64;
            let mut buffer = vec![0u16; 32_768];
            let len = GetModuleFileNameW(module, buffer.as_mut_ptr(), buffer.len() as u32);
            let _ = FreeLibrary(module);
            if len == 0 {
                return None;
            }
            buffer.truncate(len as usize);
            Some(Self {
                path: PathBuf::from(std::ffi::OsString::from_wide(&buffer)),
                base,
            })
        }
    }
}
