use std::path::PathBuf;

pub struct Module {
    pub path: PathBuf,
    /// The address format expected by llvm-symbolizer for this module.
    ///
    /// ELF and Mach-O addresses are object virtual addresses. Windows addresses are
    /// relative virtual addresses and must be passed with `--relative-address`.
    pub address: u64,
}

#[cfg(unix)]
fn module_path(pc: u64) -> Option<PathBuf> {
    use std::ffi::{CStr, c_void};
    use std::os::unix::ffi::OsStrExt;

    unsafe {
        let mut info: libc::Dl_info = std::mem::zeroed();
        if libc::dladdr(pc as *const c_void, &mut info) == 0 || info.dli_fname.is_null() {
            return None;
        }

        let path = CStr::from_ptr(info.dli_fname).to_bytes();
        Some(PathBuf::from(std::ffi::OsStr::from_bytes(path)))
    }
}

#[cfg(target_os = "linux")]
struct ProgramHeaderSearch {
    pc: u64,
    load_bias: Option<u64>,
}

#[cfg(target_os = "linux")]
unsafe extern "C" fn find_elf_load_bias(
    info: *mut libc::dl_phdr_info,
    _size: libc::size_t,
    data: *mut libc::c_void,
) -> libc::c_int {
    let Some(info) = (unsafe { info.as_ref() }) else {
        return 0;
    };
    let Some(search) = (unsafe { data.cast::<ProgramHeaderSearch>().as_mut() }) else {
        return 0;
    };
    if info.dlpi_phdr.is_null() {
        return 0;
    }

    let headers =
        unsafe { std::slice::from_raw_parts(info.dlpi_phdr, usize::from(info.dlpi_phnum)) };
    let load_bias = info.dlpi_addr;
    for header in headers {
        if header.p_type != libc::PT_LOAD {
            continue;
        }
        let Some(start) = load_bias.checked_add(header.p_vaddr) else {
            continue;
        };
        let Some(end) = start.checked_add(header.p_memsz) else {
            continue;
        };
        if (start..end).contains(&search.pc) {
            search.load_bias = Some(load_bias);
            return 1;
        }
    }
    0
}

#[cfg(target_os = "linux")]
impl Module {
    pub fn from_program_counter(pc: u64) -> Option<Self> {
        let path = module_path(pc)?;
        let mut search = ProgramHeaderSearch {
            pc,
            load_bias: None,
        };
        unsafe {
            libc::dl_iterate_phdr(
                Some(find_elf_load_bias),
                std::ptr::from_mut(&mut search).cast(),
            );
        }
        let address = pc.checked_sub(search.load_bias?)?;
        Some(Self { path, address })
    }
}

#[cfg(target_os = "macos")]
#[allow(deprecated)]
impl Module {
    pub fn from_program_counter(pc: u64) -> Option<Self> {
        use std::ffi::c_void;

        let path = module_path(pc)?;
        unsafe {
            let mut info: libc::Dl_info = std::mem::zeroed();
            if libc::dladdr(pc as *const c_void, &mut info) == 0 || info.dli_fbase.is_null() {
                return None;
            }

            let image_header = info.dli_fbase.cast_const().cast::<libc::mach_header>();
            for index in 0..libc::_dyld_image_count() {
                if libc::_dyld_get_image_header(index) != image_header {
                    continue;
                }
                let slide = libc::_dyld_get_image_vmaddr_slide(index);
                let address = if slide >= 0 {
                    pc.checked_sub(slide as u64)?
                } else {
                    pc.checked_add(slide.unsigned_abs() as u64)?
                };
                return Some(Self { path, address });
            }
        }
        None
    }
}

#[cfg(all(unix, not(any(target_os = "linux", target_os = "macos"))))]
impl Module {
    pub fn from_program_counter(pc: u64) -> Option<Self> {
        use std::ffi::c_void;

        let path = module_path(pc)?;
        unsafe {
            let mut info: libc::Dl_info = std::mem::zeroed();
            if libc::dladdr(pc as *const c_void, &mut info) == 0 || info.dli_fbase.is_null() {
                return None;
            }
            let address = pc.checked_sub(info.dli_fbase as u64)?;
            Some(Self { path, address })
        }
    }
}

#[cfg(windows)]
impl Module {
    pub fn from_program_counter(pc: u64) -> Option<Self> {
        use std::os::windows::ffi::OsStringExt;
        use windows_sys::Win32::System::LibraryLoader::{
            GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
            GetModuleFileNameW, GetModuleHandleExW,
        };

        unsafe {
            let mut module = std::ptr::null_mut();

            let flags = GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS
                | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT;

            if GetModuleHandleExW(flags, pc as usize as *const u16, &mut module) == 0 {
                return None;
            }

            let base = module as usize as u64;

            let mut buffer = vec![0u16; 32_768];
            let len = GetModuleFileNameW(module, buffer.as_mut_ptr(), buffer.len() as u32);

            if len == 0 {
                return None;
            }

            buffer.truncate(len as usize);

            Some(Module {
                path: PathBuf::from(std::ffi::OsString::from_wide(&buffer)),
                address: pc.checked_sub(base)?,
            })
        }
    }
}
