//! Backtrace metadata types for attaching source-location information to gates.
//!
//! Backtraces are captured at the call site as a sequence of
//! [`CapturedFrame`] entries, each carrying the raw loaded virtual
//! address (VMA) of the corresponding instruction pointer in the
//! captured process. A VMA of `0` is a sentinel for "module unknown"
//! (e.g. JIT'd code or anonymous mappings).
//!
//! Module-table entries ([`ResolvedModule`]) describe each loaded
//! library as a list of loaded VMA half-open ranges plus the slide
//! ("bias") needed to translate a loaded VMA back to an in-binary
//! VMA suitable for `addr2line`. Modules are identified solely by
//! their ranges — there is no opaque module id. Consumers build a
//! VMA → module interval map from the announced module table and use
//! it to resolve each captured frame.
//!
//! Module-table entries are emitted out-of-band as
//! [`DEBUG_MODULE_TAG`] `Custom` operations; each [`DEBUG_INFO_TAG`]
//! `Custom` op carries an [`UnresolvedBacktracePayload`] referencing
//! VMAs in modules previously announced on the same stream.

use core::ptr::NonNull;
use std::collections::{HashMap, HashSet};
use std::path::PathBuf;

use addr2line::Loader;
use backtrace::{BacktraceFrame, BacktraceSymbol, Frame, trace};
use bumpalo::{Bump, boxed::Box as BumpBox, collections::vec::Vec as BumpVec};

/// Magic tag used to identify `Custom` operations carrying backtrace metadata
/// in the selene output stream. Consumers should emit a `Custom` op with this
/// tag immediately before the corresponding gate op. The payload format is
/// [`UnresolvedBacktracePayload`] (msgpack).
pub const DEBUG_INFO_TAG: usize = 0x6fcfc512e44136eb;

/// Magic tag used to identify `Custom` operations carrying module-table
/// entries. Each such op carries a single [`ResolvedModule`] (msgpack) and
/// must be emitted on the stream before any [`DEBUG_INFO_TAG`] op that
/// references VMAs falling within its ranges.
pub const DEBUG_MODULE_TAG: usize = 0x6fcfc512e44136ec;

/// A single captured frame: the loaded virtual address of the
/// instruction pointer at capture time.
///
/// A `vma` of `0` is the sentinel for "module unknown" (e.g. JIT'd
/// code or anonymous mappings); program IPs are never NULL on any
/// supported platform, so the encoding is unambiguous. Non-zero VMAs
/// are resolved by looking up the containing [`ResolvedModule`] via
/// its `ranges` and computing `svma = vma - module.bias`.
#[derive(Copy, Clone, Debug, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub struct CapturedFrame {
    pub vma: u64,
}

type BoxedBacktrace<'b> = BumpBox<'b, UnresolvedBacktrace<'b>>;

/// A partially-captured backtrace whose frames have not yet been resolved.
struct UnresolvedBacktrace<'bump> {
    pub frames: BumpVec<'bump, CapturedFrame>,
}

impl<'bump> UnresolvedBacktrace<'bump> {
    fn new_boxed(alloc: &'bump Bump, capacity: usize) -> BoxedBacktrace<'bump> {
        BumpBox::new_in(
            Self {
                frames: BumpVec::with_capacity_in(capacity, alloc),
            },
            alloc,
        )
    }
}

/// Wire-format module entry. Emitted into the trace as a
/// [`DEBUG_MODULE_TAG`] `Custom` op so downstream consumers can resolve
/// captured frames without access to the live process.
///
/// `ranges` is a list of non-overlapping half-open `[start, end)`
/// intervals of loaded VMAs occupied by the module (one per PT_LOAD
/// / Mach-O segment / PE image, depending on platform). `bias` is the
/// runtime slide: `svma = vma - bias` yields an in-binary VMA that,
/// after adjusting by `Loader::relative_address_base()`, can be fed
/// to `addr2line` / `symbolic` for resolution.
#[derive(Clone, Debug, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub struct ResolvedModule {
    pub path: String,
    pub bias: u64,
    pub ranges: Vec<(u64, u64)>,
}

impl ResolvedModule {
    /// Serialise to MessagePack bytes using named fields.
    pub fn serialize_msgpack(&self) -> Result<Vec<u8>, rmp_serde::encode::Error> {
        rmp_serde::to_vec_named(self)
    }
}

/// Wire-format payload for a [`DEBUG_INFO_TAG`] `Custom` op.
///
/// `frames` is a list of [`CapturedFrame`] entries; the `vma` of each
/// frame is resolved by finding the [`ResolvedModule`] whose `ranges`
/// contain it, as announced earlier on the stream via
/// [`DEBUG_MODULE_TAG`] ops.
#[derive(Clone, Debug, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub struct UnresolvedBacktracePayload {
    pub frames: Vec<CapturedFrame>,
}

impl UnresolvedBacktracePayload {
    /// Serialise to MessagePack bytes using named fields.
    pub fn serialize_msgpack(&self) -> Result<Vec<u8>, rmp_serde::encode::Error> {
        rmp_serde::to_vec_named(self)
    }
}

/// Information about a single loaded module: the runtime slide
/// ("bias"), the on-disk path, and the list of loaded VMA half-open
/// ranges occupied by the module in the captured process.
struct ModuleLoadInfo {
    base: usize,
    path: PathBuf,
    ranges: Vec<(u64, u64)>,
}

/// Look up the module containing `ip` and return its load base, path,
/// and full set of loaded VMA ranges. Returns `None` if no module can
/// be identified.
#[cfg(target_os = "linux")]
fn module_for_ip(ip: usize) -> Option<ModuleLoadInfo> {
    use std::ffi::CStr;
    use std::os::raw::{c_int, c_void};

    struct Probe {
        ip: usize,
        found: Option<ModuleLoadInfo>,
    }

    unsafe extern "C" fn cb(
        info: *mut libc::dl_phdr_info,
        _size: libc::size_t,
        data: *mut c_void,
    ) -> c_int {
        // SAFETY: dl_iterate_phdr guarantees `info` and `data` are valid for
        // the duration of the callback.
        let probe = unsafe { &mut *(data as *mut Probe) };
        let info = unsafe { &*info };
        let base = info.dlpi_addr as usize;

        let mut ranges: Vec<(u64, u64)> = Vec::new();
        let phdrs = unsafe { std::slice::from_raw_parts(info.dlpi_phdr, info.dlpi_phnum as usize) };
        for ph in phdrs {
            if ph.p_type == libc::PT_LOAD {
                let start = (info.dlpi_addr as u64).wrapping_add(ph.p_vaddr as u64);
                let end = start.wrapping_add(ph.p_memsz as u64);
                ranges.push((start, end));
            }
        }

        let ip64 = probe.ip as u64;
        if !ranges.iter().any(|(s, e)| ip64 >= *s && ip64 < *e) {
            return 0; // not this module, keep iterating
        }

        let name = if info.dlpi_name.is_null() || unsafe { *info.dlpi_name } == 0 {
            // Empty name => the main executable. Try to recover via /proc/self/exe.
            std::fs::read_link("/proc/self/exe")
                .ok()
                .unwrap_or_default()
        } else {
            let cstr = unsafe { CStr::from_ptr(info.dlpi_name) };
            match cstr.to_str() {
                Ok(s) => PathBuf::from(s),
                Err(_) => return 0,
            }
        };

        probe.found = Some(ModuleLoadInfo {
            base,
            path: name,
            ranges,
        });
        1 // stop iterating
    }

    let mut probe = Probe { ip, found: None };
    // SAFETY: callback is C ABI; we pass a valid pointer to our local Probe.
    unsafe {
        libc::dl_iterate_phdr(Some(cb), &mut probe as *mut Probe as *mut c_void);
    }
    probe.found
}

#[cfg(target_os = "macos")]
#[allow(deprecated)] // libc routes mach-o lookups via deprecated items; mach2 would be the alternative
fn module_for_ip(ip: usize) -> Option<ModuleLoadInfo> {
    use std::ffi::CStr;

    // Repr-compatible subset of mach-o load_command / segment_command_64.
    // We use libc's struct definitions directly when available.
    let ip64 = ip as u64;
    // SAFETY: _dyld_image_count returns the current number of loaded images.
    let count = unsafe { libc::_dyld_image_count() };
    for i in 0..count {
        // SAFETY: i is in range [0, count).
        let header = unsafe { libc::_dyld_get_image_header(i) };
        if header.is_null() {
            continue;
        }
        let slide = unsafe { libc::_dyld_get_image_vmaddr_slide(i) } as u64;

        // SAFETY: _dyld_get_image_header returns a pointer to a valid
        // mach_header / mach_header_64 (one per loaded image).
        let header64: &libc::mach_header_64 = unsafe { &*(header as *const libc::mach_header_64) };
        let ncmds = header64.ncmds as usize;

        let mut ranges: Vec<(u64, u64)> = Vec::new();
        let mut cmd_ptr =
            unsafe { (header as *const u8).add(std::mem::size_of::<libc::mach_header_64>()) };
        for _ in 0..ncmds {
            // SAFETY: load commands are laid out contiguously after the
            // header, each prefixed with a `load_command` header that
            // carries `cmdsize`.
            let lc: &libc::load_command = unsafe { &*(cmd_ptr as *const libc::load_command) };
            if lc.cmd == libc::LC_SEGMENT_64 {
                let seg: &libc::segment_command_64 =
                    unsafe { &*(cmd_ptr as *const libc::segment_command_64) };
                if seg.vmsize > 0 {
                    let start = (seg.vmaddr as u64).wrapping_add(slide);
                    let end = start.wrapping_add(seg.vmsize as u64);
                    ranges.push((start, end));
                }
            }
            cmd_ptr = unsafe { cmd_ptr.add(lc.cmdsize as usize) };
        }

        if !ranges.iter().any(|(s, e)| ip64 >= *s && ip64 < *e) {
            continue;
        }

        // SAFETY: _dyld_get_image_name returns a NUL-terminated C string
        // owned by dyld; we copy it immediately.
        let name_ptr = unsafe { libc::_dyld_get_image_name(i) };
        if name_ptr.is_null() {
            continue;
        }
        let path = match unsafe { CStr::from_ptr(name_ptr) }.to_str() {
            Ok(s) => PathBuf::from(s),
            Err(_) => continue,
        };

        return Some(ModuleLoadInfo {
            base: header as usize,
            path,
            ranges,
        });
    }
    None
}

#[cfg(windows)]
fn module_for_ip(ip: usize) -> Option<ModuleLoadInfo> {
    use std::ffi::OsString;
    use std::os::windows::ffi::OsStringExt;
    use windows_sys::Win32::Foundation::HMODULE;
    use windows_sys::Win32::System::LibraryLoader::{
        GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        GetModuleFileNameW, GetModuleHandleExW,
    };
    use windows_sys::Win32::System::ProcessStatus::{GetModuleInformation, MODULEINFO};
    use windows_sys::Win32::System::Threading::GetCurrentProcess;

    let mut hmod: HMODULE = std::ptr::null_mut();
    // SAFETY: passing a stack-allocated out pointer. The
    // UNCHANGED_REFCOUNT flag means we do not need to FreeLibrary.
    let ok = unsafe {
        GetModuleHandleExW(
            GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
            ip as *const u16,
            &mut hmod,
        )
    };
    if ok == 0 || hmod.is_null() {
        return None;
    }
    let mut buf = vec![0u16; 1024];
    // SAFETY: buf is a valid mutable u16 slice of size buf.len().
    let n = unsafe { GetModuleFileNameW(hmod, buf.as_mut_ptr(), buf.len() as u32) };
    if n == 0 {
        return None;
    }
    buf.truncate(n as usize);
    let path = PathBuf::from(OsString::from_wide(&buf));

    // SAFETY: MODULEINFO is plain-old-data; zero-init is safe.
    let mut info: MODULEINFO = unsafe { std::mem::zeroed() };
    // SAFETY: hmod is a valid module handle obtained above; passing
    // GetCurrentProcess() pseudo-handle is documented and safe.
    let got = unsafe {
        GetModuleInformation(
            GetCurrentProcess(),
            hmod,
            &mut info,
            std::mem::size_of::<MODULEINFO>() as u32,
        )
    };
    let base = hmod as usize;
    let ranges = if got != 0 && !info.lpBaseOfDll.is_null() && info.SizeOfImage > 0 {
        let start = info.lpBaseOfDll as u64;
        let end = start.wrapping_add(info.SizeOfImage as u64);
        vec![(start, end)]
    } else {
        // Fall back to a degenerate single-range entry rooted at the
        // module handle; size-unknown loaders are rare in practice.
        Vec::new()
    };

    Some(ModuleLoadInfo { base, path, ranges })
}

#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
fn module_for_ip(_ip: usize) -> Option<ModuleLoadInfo> {
    None
}

/// Per-module information retained by the [`BacktraceEngine`].
///
/// `path` and `ranges` are only populated for modules that have not
/// yet been drained via [`BacktraceEngine::drain_pending_modules`];
/// once drained, the engine drops them and keeps only the bias
/// needed for future SVMA arithmetic on the same module.
struct ModuleInfo {
    bias: usize,
    path: Option<PathBuf>,
    ranges: Option<Vec<(u64, u64)>>,
}

/// Count the number of frames between the caller of `trace` and the frame
/// where the closure executes. Returns the index of the caller in the trace.
#[inline(never)]
fn calibrate_global_frame_skip() -> usize {
    let mut frame_count = 0;

    backtrace::trace(|frame| {
        let mut frame: BacktraceFrame = frame.clone().into();
        frame.resolve();
        for (_i, sym) in frame.symbols().iter().enumerate() {
            let name = sym.name().expect("should be symbolicated").to_string();
            if name.contains("calibrate_global_frame_skip") {
                debug_assert!(
                    _i == frame.symbols().len() - 1,
                    "target should not be inlined"
                );
                return false; // we have reached the frame of the calling function
            }
        }

        // not found, keep searching
        frame_count += 1;
        true
    });

    // +1 because we want the caller of the caller of `trace`,
    // a.k.a. the caller of `capture_backtrace`
    frame_count + 1
}

/// Class which manages backtraces, including efficient allocation and deduplication.
pub struct BacktraceEngine<'bump> {
    /// Set of function names used as "interface frames".
    /// Backtraces are collected starting at the callers of these frames.
    interface_fns: HashSet<String>,
    /// Map from backtrace hash to existing backtraces
    /// The key is the hash itself - the lookup is only used when a new backtrace is
    /// constructed, to perform deduplication. For performance, we create the hash as part
    /// of constructing the backtrace rather than implementing Hash.
    existing_traces: HashMap<u64, NonNull<UnresolvedBacktrace<'bump>>>,
    /// The global frame skip is the frame index of the caller of `capture_backtrace`,
    /// which can vary based on compile-time inlining decisions. It is calculated when the
    /// engine is constructed by calling `calibrate_global_frame_skip`. The IP of the
    /// frame at this index is considered the unique identifier of a call site, and is
    /// used as a key to `site_frame_skips`.
    global_frame_skip: usize,
    /// Map from call-site IP to the number of frames to skip for that call site.
    /// The call-site IP is the IP of the direct caller of `capture_backtrace`.
    /// Calibrated once per unique call site.
    site_frame_skips: HashMap<usize, usize>,
    /// Landing zone for trace data (see capture_backtrace)  
    staging: Option<BoxedBacktrace<'bump>>,
    /// Cache of modules encountered so far. Indexed by `module_id`
    /// (allocated sequentially).
    modules: Vec<ModuleInfo>,
    /// Lookup of `module_id` by module load base (dli_fbase / HMODULE).
    module_by_base: HashMap<usize, u32>,
    /// Module ids discovered since the last drain. Drained as
    /// [`ResolvedModule`] payloads via
    /// [`BacktraceEngine::drain_pending_modules`].
    pending_modules: Vec<u32>,
    // TODO: enforce and remove lifetime hacking
    /// Bump allocator which provides backing memory. Must be dropped last!
    allocator: Bump,
}

impl<'bump> BacktraceEngine<'bump> {
    /// Create a new `BacktraceEngine`.
    ///
    /// Args:
    /// - interface_fns: a set of function names which define the boundary between
    ///   Selene and user code (i.e., where we want to start saving frames).
    ///   This should be provided by the interface plugin.
    ///
    /// - user_skip: The number of frames between the `RuntimePlugin` trait methods
    ///   and the call to `create_backtrace`. For instance, the simple
    ///   runtime's interface methods call a `push` method which creates the actual
    ///   backtrace, so it sets user_skip=1.
    ///
    ///   This value must be the same for all backtraces created with a given
    ///   `BacktraceEngine`. In addition, intermediate frames included in the count
    ///   must be marked with the `inline(never)` attribute to ensure the skip count
    ///   remains correct across all build configurations.
    pub fn new(interface_fns: impl IntoIterator<Item: AsRef<str>>, user_skip: usize) -> Self {
        Self {
            interface_fns: interface_fns
                .into_iter()
                .map(|s| s.as_ref().to_owned())
                .collect(),
            existing_traces: Default::default(),
            global_frame_skip: calibrate_global_frame_skip() + user_skip,
            site_frame_skips: Default::default(),
            staging: Default::default(),
            modules: Default::default(),
            module_by_base: Default::default(),
            pending_modules: Default::default(),
            allocator: Default::default(),
        }
    }

    fn is_interface_frame(&self, sym: &BacktraceSymbol) -> bool {
        let name = sym
            .name()
            .expect("symbols passed to this function should be symbolicated")
            .to_string();

        // On macOS the Darwin linker prepends an extra '_' to C symbols,
        // remove it before checking for matches
        let name_canonical = if std::env::consts::OS == "macos" {
            name.strip_prefix('_').unwrap_or(&name)
        } else {
            &name
        };

        self.interface_fns.contains(name_canonical)
    }

    const MAX_FRAMES_TO_SEARCH: usize = 10;

    /// Get the frame skip count for the given call-site IP, calibrating if not yet known.
    ///
    /// `call_site_ip` should be the IP of frame index 1 as seen from within
    /// `capture_backtrace` (i.e. the direct caller of `capture_backtrace`).
    #[inline(always)]
    fn get_frame_skip(&mut self, call_site_ip: usize) -> usize {
        if let Some(&skip_count) = self.site_frame_skips.get(&call_site_ip) {
            skip_count
        } else {
            let mut skip_count = 0;
            backtrace::trace(|abstract_frame| {
                let mut frame: BacktraceFrame = abstract_frame.clone().into();
                frame.resolve();
                let syms = frame.symbols();
                for (i, sym) in syms.iter().enumerate() {
                    if self.is_interface_frame(sym) {
                        // must be the outermost symbol in the frame (not inlined)
                        if i != syms.len() - 1 {
                            panic!("interface frame was inlined, or detection function is wrong")
                        }
                        return false; // we have found an interface frame
                    }
                }

                debug_assert!(
                    skip_count != (self.global_frame_skip - 1)
                        || syms
                            .iter()
                            .last()
                            .unwrap()
                            .name()
                            .unwrap()
                            .to_string()
                            .contains("capture_backtrace"),
                    "global skip count calibrated incorrectly"
                );

                // frame not found, continue until we hit the max
                skip_count += 1;
                skip_count < Self::MAX_FRAMES_TO_SEARCH
            });

            if skip_count == Self::MAX_FRAMES_TO_SEARCH {
                panic!(
                    "Could not find interface frame for debug backtrace within {} frames",
                    Self::MAX_FRAMES_TO_SEARCH
                );
            }

            // +1 because we want the caller of the interface frame
            skip_count += 1;

            self.site_frame_skips.insert(call_site_ip, skip_count);
            skip_count
        }
    }

    /// Look up or insert the module containing `ip`. Returns the
    /// module's load base (used purely for bias arithmetic). New entries
    /// are recorded in `pending_modules` for emission via
    /// [`drain_pending_modules`](Self::drain_pending_modules). Returns
    /// `None` when no module can be identified (JIT'd code, anonymous
    /// mappings, etc.).
    fn module_for_ip_cached(&mut self, ip: usize) -> Option<usize> {
        if let Some(info) = module_for_ip(ip) {
            let base = info.base;
            if self.module_by_base.contains_key(&base) {
                return Some(base);
            }
            let id =
                u32::try_from(self.modules.len()).expect("more than u32::MAX modules captured");
            self.modules.push(ModuleInfo {
                bias: base,
                path: Some(info.path),
                ranges: Some(info.ranges),
            });
            self.module_by_base.insert(base, id);
            self.pending_modules.push(id);
            Some(base)
        } else {
            None
        }
    }

    #[inline(never)]
    pub fn capture_backtrace(&mut self, n_capture: usize) -> u64 {
        // Capture the IP of the direct caller of this function
        let mut call_site_ip: usize = 0;
        let mut frame_idx = 0usize;
        trace(|frame: &Frame| {
            if frame_idx == self.global_frame_skip {
                call_site_ip = frame.ip() as usize;
                false // stop after finding the call site
            } else {
                frame_idx += 1;
                true
            }
        });

        let frame_skip = self.get_frame_skip(call_site_ip);
        // We need to pass a `'bump Bump` to use the bumpalo containers.
        // But we cannot safely materialize a `&'bump self`, because rustc is not
        // convinced that Self outlives the Bump. So we do this instead.
        // TODO: make this safe by adding a nested struct
        let alloc_casted: &'bump Bump = unsafe { &*(&self.allocator as *const Bump) };

        // Take the staging box out of `self` for the duration of the
        // trace closure. This lets the closure call
        // `self.module_for_ip_cached` (which borrows `&mut self`)
        // while simultaneously pushing into the staged frames vector,
        // without violating Rust's aliasing rules.
        let mut staged_box = self
            .staging
            .take()
            .unwrap_or_else(|| UnresolvedBacktrace::new_boxed(alloc_casted, n_capture));

        let mut hash: u64 = 0;
        let mut count = 0;
        let limit = n_capture + frame_skip;
        trace(|frame: &Frame| {
            if count < frame_skip {
                count += 1;
                return true;
            }
            // Resolve the module to register it in pending_modules
            // (consumers need module entries to look up VMAs at
            // resolution time), but the frame itself carries only the
            // raw loaded VMA. `0` is reserved as the sentinel for
            // "module unknown".
            let ip = frame.ip() as usize;
            let vma: u64 = match self.module_for_ip_cached(ip) {
                Some(_) => ip as u64,
                None => 0,
            };
            // Mix only the VMA: distinct modules occupy disjoint loaded
            // address ranges, so VMAs are globally unique without
            // requiring a module identifier.
            hash = hash.rotate_left(13) ^ (vma.wrapping_mul(0x9E3779B97F4A7C15));
            staged_box.frames.push(CapturedFrame { vma });
            count += 1;
            count < limit
        });

        if count <= frame_skip {
            panic!(
                "Did not get at least `frame_skip` ({frame_skip}) frames in `capture_backtrace`; \
                this should not happen if the backtrace is properly calibrated."
            );
        }

        if let Some(existing) = self.existing_traces.get(&hash) {
            // existing entry: return it, recycling the staging object.
            staged_box.frames.clear();
            self.staging = Some(staged_box);
            existing.as_ptr() as u64
        } else {
            // no existing entry: hand the staging object off as a raw pointer.
            // SAFETY: staged_box was just created or taken from self.staging,
            // both of which yield a valid non-null BumpBox.
            let raw_ptr = unsafe { NonNull::new_unchecked(BumpBox::into_raw(staged_box)) };
            let _ = self.existing_traces.insert(hash, raw_ptr);
            raw_ptr.as_ptr() as u64
        }
    }

    /// Drain any modules discovered since the last call. Each
    /// [`ResolvedModule`] should be emitted into the operation stream as
    /// a `Custom` op with tag [`DEBUG_MODULE_TAG`] before any
    /// subsequent [`DEBUG_INFO_TAG`] op that references VMAs falling
    /// within its ranges.
    ///
    /// After draining, the engine drops the module paths and ranges and
    /// retains only the bias needed for future captures on the same
    /// modules.
    pub fn drain_pending_modules(&mut self) -> Vec<ResolvedModule> {
        let mut out = Vec::with_capacity(self.pending_modules.len());
        for id in self.pending_modules.drain(..) {
            let info = &mut self.modules[id as usize];
            let path = info
                .path
                .take()
                .expect("pending module should still have its path");
            let ranges = info
                .ranges
                .take()
                .expect("pending module should still have its ranges");
            out.push(ResolvedModule {
                path: path.to_string_lossy().into_owned(),
                bias: info.bias as u64,
                ranges,
            });
        }
        out
    }

    /// Serialise each pending module as a separate msgpack blob, ready
    /// to be wrapped in `Custom { tag: DEBUG_MODULE_TAG, data }` ops.
    pub fn serialize_pending_modules(&mut self) -> Result<Vec<Vec<u8>>, rmp_serde::encode::Error> {
        self.drain_pending_modules()
            .iter()
            .map(|m| m.serialize_msgpack())
            .collect()
    }

    /// Serialise the captured backtrace identified by `bt_ref` as the
    /// payload for a `Custom { tag: DEBUG_INFO_TAG, data }` op.
    ///
    /// `bt_ref` must have been returned by a prior call to
    /// [`capture_backtrace`](Self::capture_backtrace) on this engine,
    /// and the engine must not yet have been dropped.
    pub fn serialize_backtrace(&self, bt_ref: u64) -> Result<Vec<u8>, rmp_serde::encode::Error> {
        let ptr =
            NonNull::new(bt_ref as *mut UnresolvedBacktrace).expect("`bt_ref` should be nonzero");
        // SAFETY: `bt_ref` was returned by `capture_backtrace` on this
        // engine, whose bump arena is still alive (engine not dropped).
        let bt = unsafe { ptr.as_ref() };
        let payload = UnresolvedBacktracePayload {
            frames: bt.frames.iter().copied().collect(),
        };
        payload.serialize_msgpack()
    }
}

/// Abstraction over a per-op metadata store used at serialisation time.
///
/// The host (selene-sim) holds a backtrace engine and threads it through to
/// event hooks via `EventHook::write`, where each hook can lazily resolve any
/// metadata handles it has recorded into the wire-format `Custom` ops.
impl<'bump> Drop for BacktraceEngine<'bump> {
    /// Manually drop all `UnresolvedBacktrace`s before the memory is deallocated
    /// when `self.allocator` is auto-dropped.
    fn drop(&mut self) {
        for ptr in self.existing_traces.values() {
            // SAFETY: all members of `existing_traces` must be pointers to a valid
            // value which has not yet been dropped.
            let _ = unsafe { BumpBox::from_raw(ptr.as_ptr()) };
        }
    }
}

/// Wire-format representation of a single symbolicated backtrace frame.
/// Must match the definition of selene_core.trace.SrcLocation
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct ResolvedSrcLocation {
    pub function_name: String,
    pub file_name: Option<String>,
    pub line: Option<u32>,
    pub column: Option<u32>,
}

impl ResolvedSrcLocation {
    fn unknown() -> Self {
        Self {
            function_name: "<unknown>".to_string(),
            file_name: None,
            line: None,
            column: None,
        }
    }
}

/// Wire-format representation of a resolved backtrace, ready for serialisation.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct ResolvedBacktrace {
    pub frames: Vec<ResolvedSrcLocation>,
}

impl ResolvedBacktrace {
    /// Resolve a captured backtrace using a previously emitted module
    /// table. `modules` is the list of [`ResolvedModule`] entries
    /// announced earlier on the stream; a sorted interval index is
    /// built over their ranges to locate each frame's module.
    ///
    /// Each owning module's on-disk binary is opened (at most once per
    /// call) with [`addr2line::Loader`]; one [`ResolvedSrcLocation`]
    /// is emitted per inlined frame returned by `find_frames`. Frames
    /// whose VMA falls outside every range, whose owning binary cannot
    /// be opened, or whose SVMA does not resolve, produce an
    /// `<unknown>` placeholder.
    pub fn from_unresolved(frames: &[CapturedFrame], modules: &[ResolvedModule]) -> Self {
        // Build sorted (start, end, module_idx) intervals.
        let mut intervals: Vec<(u64, u64, usize)> =
            Vec::with_capacity(modules.iter().map(|m| m.ranges.len()).sum());
        for (idx, m) in modules.iter().enumerate() {
            for &(start, end) in &m.ranges {
                if end > start {
                    intervals.push((start, end, idx));
                }
            }
        }
        intervals.sort_by_key(|(start, _, _)| *start);

        let find_module = |vma: u64| -> Option<usize> {
            if vma == 0 {
                return None;
            }
            // partition_point finds first interval with start > vma; the
            // candidate is the one just before it.
            let idx = intervals.partition_point(|(start, _, _)| *start <= vma);
            if idx == 0 {
                return None;
            }
            let (start, end, mod_idx) = intervals[idx - 1];
            if vma >= start && vma < end {
                Some(mod_idx)
            } else {
                None
            }
        };

        let mut loaders: HashMap<usize, Option<Loader>> = HashMap::new();
        let mut out = Self {
            frames: Vec::with_capacity(frames.len()),
        };

        for f in frames {
            let Some(mod_idx) = find_module(f.vma) else {
                out.frames.push(ResolvedSrcLocation::unknown());
                continue;
            };
            let module = &modules[mod_idx];
            let loader = loaders
                .entry(mod_idx)
                .or_insert_with(|| Loader::new(&module.path).ok());
            let Some(loader) = loader.as_ref() else {
                out.frames.push(ResolvedSrcLocation::unknown());
                continue;
            };

            let svma = f.vma.wrapping_sub(module.bias);
            // addr2line expects a VMA in the binary's address space.
            // Our svma is module-load-relative (vma - bias). Add the
            // loader's relative_address_base to convert. On ELF PIE
            // builds this is 0; on Mach-O it's the lowest __TEXT vmaddr.
            let probe = svma.wrapping_add(loader.relative_address_base());

            let mut pushed = 0usize;
            if let Ok(mut iter) = loader.find_frames(probe) {
                while let Ok(Some(frame)) = iter.next() {
                    let function_name = frame
                        .function
                        .as_ref()
                        .and_then(|fn_| fn_.demangle().ok().map(|s| s.into_owned()))
                        .unwrap_or_else(|| "<unknown>".to_string());
                    let (file_name, line, column) = match frame.location {
                        Some(loc) => (loc.file.map(|s| s.to_string()), loc.line, loc.column),
                        None => (None, None, None),
                    };
                    out.frames.push(ResolvedSrcLocation {
                        function_name,
                        file_name,
                        line,
                        column,
                    });
                    pushed += 1;
                }
            }
            if pushed == 0 {
                out.frames.push(ResolvedSrcLocation::unknown());
            }
        }
        out
    }

    /// Serialise to MessagePack bytes using named fields.
    pub fn serialize_msgpack(&self) -> Result<Vec<u8>, rmp_serde::encode::Error> {
        rmp_serde::to_vec_named(self)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[inline(never)]
    extern "C" fn frame0(engine: *mut BacktraceEngine, n_cap: usize) -> u64 {
        let engine = unsafe { &mut *engine };
        engine.capture_backtrace(n_cap)
    }

    #[inline(never)]
    fn frame1(engine: &mut BacktraceEngine, n_cap: usize) -> u64 {
        frame0(engine as *mut BacktraceEngine, n_cap)
    }

    // this function serves as the anchor frame for the first synthetic call chain.
    //
    // no_mangle is used only to ensure the name is preserved -
    // this module is not intended for FFI use.
    #[inline(never)]
    #[unsafe(no_mangle)]
    fn selene_frame(engine: *mut BacktraceEngine, n_cap: usize) -> u64 {
        let eref = unsafe { &mut *engine };
        frame1(eref, n_cap)
    }

    #[inline(never)]
    fn frame3(engine: *mut BacktraceEngine, n_cap: usize) -> u64 {
        selene_frame(engine, n_cap)
    }

    #[inline(never)]
    fn cap_synth_backtrace(engine: &mut BacktraceEngine, n_cap: usize) -> u64 {
        frame3(engine, n_cap)
    }

    /// Helper: drain modules from the engine and return as a Vec for use with
    /// `ResolvedBacktrace::from_unresolved`.
    fn drain_modules(engine: &mut BacktraceEngine) -> Vec<ResolvedModule> {
        engine.drain_pending_modules()
    }

    /// Helper: dereference a bt_ref into the captured frame slice (test only).
    fn frames_of(bt_ref: u64) -> Vec<CapturedFrame> {
        let ptr = NonNull::new(bt_ref as *mut UnresolvedBacktrace).unwrap();
        // SAFETY: bt_ref returned by capture_backtrace on a still-live engine.
        let bt = unsafe { ptr.as_ref() };
        bt.frames.iter().copied().collect()
    }

    #[test]
    fn test_create_captures_frames() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 3);
        let frames = frames_of(bt_ref);
        assert!(!frames.is_empty(), "expected at least one captured frame");
        // At least one frame should have a non-zero VMA (i.e. its
        // owning module was identified).
        assert!(
            frames.iter().any(|f| f.vma != 0),
            "expected at least one frame with a known VMA"
        );
    }

    #[test]
    fn test_deduplication() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt1 = cap_synth_backtrace(&mut engine, 1);
        let bt2 = cap_synth_backtrace(&mut engine, 1);
        assert!(bt1 == bt2, "expected backtraces to be deduplicated");
    }

    #[test]
    fn test_module_cache_dedup() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let _ = cap_synth_backtrace(&mut engine, 3);
        let first = engine.drain_pending_modules();
        assert!(
            !first.is_empty(),
            "first capture should announce at least one module"
        );
        // Each emitted module should have at least one range.
        for m in &first {
            assert!(
                !m.ranges.is_empty(),
                "emitted module {} should have at least one VMA range",
                m.path
            );
        }
        let _ = cap_synth_backtrace(&mut engine, 3);
        let second = engine.drain_pending_modules();
        assert!(
            second.is_empty(),
            "second capture from same modules should announce no new modules, got {second:?}"
        );
    }

    #[test]
    fn test_module_payload_roundtrip() {
        let m = ResolvedModule {
            path: "/tmp/example.so".to_string(),
            bias: 0x1234_5678,
            ranges: vec![(0x1234_5000, 0x1234_8000), (0x1234_9000, 0x1234_a000)],
        };
        let bytes = m.serialize_msgpack().unwrap();
        let decoded: ResolvedModule = rmp_serde::from_slice(&bytes).unwrap();
        assert_eq!(m, decoded);
    }

    #[test]
    fn test_backtrace_payload_roundtrip() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 3);
        let bytes = engine.serialize_backtrace(bt_ref).unwrap();
        let decoded: UnresolvedBacktracePayload = rmp_serde::from_slice(&bytes).unwrap();
        assert!(!decoded.frames.is_empty());
        // Frame contents should match what's in the engine's storage.
        let direct = frames_of(bt_ref);
        assert_eq!(direct, decoded.frames);
    }

    #[test]
    fn test_captured_vmas_lie_in_module_ranges() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 5);
        let frames = frames_of(bt_ref);
        let modules = drain_modules(&mut engine);
        assert!(!modules.is_empty(), "expected at least one drained module");
        for f in &frames {
            if f.vma == 0 {
                continue;
            }
            let in_range = modules
                .iter()
                .any(|m| m.ranges.iter().any(|(s, e)| f.vma >= *s && f.vma < *e));
            assert!(
                in_range,
                "VMA {:#x} does not fall within any drained module's ranges",
                f.vma
            );
        }
    }

    #[test]
    fn test_zero_vma_resolves_to_unknown() {
        let frames = vec![CapturedFrame { vma: 0 }];
        let resolved = ResolvedBacktrace::from_unresolved(&frames, &[]);
        assert_eq!(resolved.frames.len(), 1);
        assert_eq!(resolved.frames[0].function_name, "<unknown>");
        assert!(resolved.frames[0].file_name.is_none());
    }

    #[test]
    fn test_resolved_has_symbols() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 5);
        let frames = frames_of(bt_ref);
        let modules = drain_modules(&mut engine);
        let resolved = ResolvedBacktrace::from_unresolved(&frames, &modules);
        assert_eq!(
            resolved.frames.len() >= frames.len(),
            true,
            "expected at least one resolved entry per captured frame"
        );

        // Symbol presence depends on DWARF being readable from the
        // on-disk binary. On macOS this requires a dSYM bundle next to
        // the test binary (created by `dsymutil`); cargo test doesn't
        // run dsymutil by default, so we skip the strict check when no
        // debug info is reachable. On Linux PIE this normally works
        // out of the box.
        let debug_info_available = modules.iter().any(|m| {
            Loader::new(&m.path)
                .ok()
                .map(|l| {
                    frames.iter().any(|f| {
                        if f.vma == 0 {
                            return false;
                        }
                        let svma = f.vma.wrapping_sub(m.bias);
                        let probe = svma.wrapping_add(l.relative_address_base());
                        l.find_location(probe).ok().flatten().is_some()
                    })
                })
                .unwrap_or(false)
        });
        if debug_info_available {
            assert!(
                resolved
                    .frames
                    .iter()
                    .any(|f| f.function_name != "<unknown>"),
                "expected at least one frame with a function name; got {resolved:?}"
            );
        } else {
            eprintln!(
                "[skip] no DWARF reachable from on-disk binary; \
                 symbol-presence check skipped (run dsymutil on macOS to enable)"
            );
        }
    }

    #[test]
    fn test_serialize_roundtrip() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 3);
        let frames = frames_of(bt_ref);
        let modules = drain_modules(&mut engine);
        let resolved = ResolvedBacktrace::from_unresolved(&frames, &modules);
        let bytes = resolved.serialize_msgpack().expect("serialization failed");
        let decoded: ResolvedBacktrace =
            rmp_serde::from_slice(&bytes).expect("deserialization failed");
        assert_eq!(resolved.frames.len(), decoded.frames.len());
        for (orig, dec) in resolved.frames.iter().zip(decoded.frames.iter()) {
            assert_eq!(orig.function_name, dec.function_name);
            assert_eq!(orig.file_name, dec.file_name);
            assert_eq!(orig.line, dec.line);
            assert_eq!(orig.column, dec.column);
        }
    }

    // A second synthetic call chain at a different stack depth from cap_synth_backtrace,
    // used to verify that per-call-site calibration produces a correct result for
    // both call sites independently.
    #[inline(never)]
    extern "C" fn frame0b(engine: *mut BacktraceEngine, n_cap: usize) -> u64 {
        let engine = unsafe { &mut *engine };
        engine.capture_backtrace(n_cap)
    }

    #[inline(never)]
    fn frame1b(engine: &mut BacktraceEngine, n_cap: usize) -> u64 {
        frame0b(engine as *mut BacktraceEngine, n_cap)
    }

    #[inline(never)]
    fn frame2b(engine: &mut BacktraceEngine, n_cap: usize) -> u64 {
        frame1b(engine, n_cap)
    }

    // this function serves as the anchor frame for the second synthetic call chain.
    //
    // no_mangle is used only to ensure the name is preserved -
    // this module is not intended for FFI use.
    #[inline(never)]
    #[unsafe(no_mangle)]
    fn selene_frameb(engine: *mut BacktraceEngine, n_cap: usize) -> u64 {
        let eref = unsafe { &mut *engine };
        frame2b(eref, n_cap)
    }

    #[inline(never)]
    fn frame4b(engine: *mut BacktraceEngine, n_cap: usize) -> u64 {
        selene_frameb(engine, n_cap)
    }

    #[inline(never)]
    fn cap_synth_backtrace_b(engine: &mut BacktraceEngine, n_cap: usize) -> u64 {
        frame4b(engine, n_cap)
    }

    /// Verify that two call sites at different stack depths each produce disjoint,
    /// valid, non-empty backtraces, demonstrating that per-call-site calibration works
    /// independently for each site.
    #[test]
    fn test_per_callsite_calibration() {
        let mut engine = BacktraceEngine::new(["selene_frame", "selene_frameb"], 0);

        let bt_a = cap_synth_backtrace(&mut engine, 3);
        let bt_b = cap_synth_backtrace_b(&mut engine, 3);

        let frames_a = frames_of(bt_a);
        let frames_b = frames_of(bt_b);
        let modules = drain_modules(&mut engine);

        let resolved_a = ResolvedBacktrace::from_unresolved(&frames_a, &modules);
        let resolved_b = ResolvedBacktrace::from_unresolved(&frames_b, &modules);

        assert!(
            !resolved_a.frames.is_empty(),
            "expected at least one frame from call site A"
        );
        assert!(
            !resolved_b.frames.is_empty(),
            "expected at least one frame from call site B"
        );

        // Both call sites should produce distinct backtraces.
        assert_ne!(
            bt_a, bt_b,
            "expected different backtraces from different call sites"
        );

        // Both call sites should be calibrated and cached.
        assert_eq!(
            engine.site_frame_skips.len(),
            2,
            "expected exactly two calibrated call sites"
        );
    }
}
