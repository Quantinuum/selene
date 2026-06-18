//! Backtrace metadata types for attaching source-location information to gates.
//!
//! Backtraces are captured at the call site as a sequence of
//! [`CapturedFrame`] entries, each carrying a module id and a stable
//! virtual address (SVMA) computed as `ip - module_bias`. SVMAs survive
//! ASLR and process teardown, so they can be resolved later by
//! [`ResolvedBacktrace::from_unresolved`] against the on-disk binary
//! using `addr2line`.
//!
//! The module table required for resolution is emitted out-of-band as
//! [`DEBUG_MODULE_TAG`] `Custom` operations carrying [`ResolvedModule`]
//! payloads. Each [`DEBUG_INFO_TAG`] `Custom` op carries an
//! [`UnresolvedBacktracePayload`] referencing module ids previously
//! announced on the same stream.

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
/// references its `module_id`.
pub const DEBUG_MODULE_TAG: usize = 0x6fcfc512e44136ec;

/// A single captured frame: a module identifier plus a module-relative
/// virtual address (SVMA = `ip - module_bias`).
///
/// SVMAs are stable across processes for a given on-disk binary, so this
/// representation can be persisted and resolved later via
/// [`ResolvedBacktrace::from_unresolved`].
#[derive(Copy, Clone, Debug, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub struct CapturedFrame {
    pub module_id: u32,
    pub svma: u64,
}

/// Sentinel module id used when `dladdr`/`GetModuleHandleExW` fail to
/// identify the module owning a given IP (e.g. JIT'd code, anonymous
/// mappings). Frames with this module id store the raw IP in `svma` and
/// resolve to an `<unknown>` placeholder.
pub const UNKNOWN_MODULE_ID: u32 = u32::MAX;

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
#[derive(Clone, Debug, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub struct ResolvedModule {
    pub module_id: u32,
    pub path: String,
    pub bias: u64,
}

impl ResolvedModule {
    /// Serialise to MessagePack bytes using named fields.
    pub fn serialize_msgpack(&self) -> Result<Vec<u8>, rmp_serde::encode::Error> {
        rmp_serde::to_vec_named(self)
    }
}

/// Wire-format payload for a [`DEBUG_INFO_TAG`] `Custom` op.
///
/// `frames` is a list of [`CapturedFrame`] entries; each `module_id`
/// refers to a [`ResolvedModule`] previously announced on the stream via
/// a [`DEBUG_MODULE_TAG`] op.
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

/// Look up the module containing `ip`. Returns `(module_base, path)` on
/// success, or `None` if no module can be identified.
#[cfg(unix)]
fn module_for_ip(ip: usize) -> Option<(usize, PathBuf)> {
    use std::ffi::CStr;
    // SAFETY: `Dl_info` is plain-old-data with no invalid bit patterns,
    // so zero-init is safe. `dladdr` is thread-safe on all supported
    // Unix targets.
    let mut info: libc::Dl_info = unsafe { std::mem::zeroed() };
    let ret = unsafe { libc::dladdr(ip as *const std::ffi::c_void, &mut info) };
    if ret == 0 || info.dli_fbase.is_null() || info.dli_fname.is_null() {
        return None;
    }
    // SAFETY: dli_fname is a NUL-terminated C string owned by the dynamic
    // linker. We immediately copy it into an owned PathBuf.
    let cstr = unsafe { CStr::from_ptr(info.dli_fname) };
    let path = PathBuf::from(cstr.to_str().ok()?);
    Some((info.dli_fbase as usize, path))
}

#[cfg(windows)]
fn module_for_ip(ip: usize) -> Option<(usize, PathBuf)> {
    use std::ffi::OsString;
    use std::os::windows::ffi::OsStringExt;
    use windows_sys::Win32::Foundation::HMODULE;
    use windows_sys::Win32::System::LibraryLoader::{
        GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        GetModuleFileNameW, GetModuleHandleExW,
    };

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
    Some((hmod as usize, PathBuf::from(OsString::from_wide(&buf))))
}

#[cfg(not(any(unix, windows)))]
fn module_for_ip(_ip: usize) -> Option<(usize, PathBuf)> {
    None
}

/// Per-module information retained by the [`BacktraceEngine`].
///
/// `path` is only populated for modules that have not yet been drained
/// via [`BacktraceEngine::drain_pending_modules`]; once drained, the
/// engine drops the path and keeps only the bias needed for future SVMA
/// arithmetic on the same module.
struct ModuleInfo {
    bias: usize,
    path: Option<PathBuf>,
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
    /// `module_id` and the corresponding bias. New entries are recorded
    /// in `pending_modules` for emission via
    /// [`drain_pending_modules`](Self::drain_pending_modules).
    fn module_for_ip_cached(&mut self, ip: usize) -> (u32, usize) {
        match module_for_ip(ip) {
            Some((base, path)) => {
                if let Some(&id) = self.module_by_base.get(&base) {
                    (id, base)
                } else {
                    let id = u32::try_from(self.modules.len())
                        .expect("more than u32::MAX modules captured");
                    assert!(id != UNKNOWN_MODULE_ID, "module id collides with sentinel");
                    self.modules.push(ModuleInfo {
                        bias: base,
                        path: Some(path),
                    });
                    self.module_by_base.insert(base, id);
                    self.pending_modules.push(id);
                    (id, base)
                }
            }
            // No module: store raw IP as the "svma" so we can still emit
            // something useful (and the user can debug it). Resolution
            // will yield <unknown>.
            None => (UNKNOWN_MODULE_ID, 0),
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

        // Create a new staging object if needed
        let _ = self
            .staging
            .get_or_insert_with(|| UnresolvedBacktrace::new_boxed(alloc_casted, n_capture));

        // capture the trace into the staging object. Collect raw IPs
        // first; module resolution requires &mut self and would
        // otherwise alias the staging borrow.
        let mut raw_ips: Vec<usize> = Vec::with_capacity(n_capture);
        let mut count = 0;
        let limit = n_capture + frame_skip;
        trace(|frame: &Frame| {
            if count < frame_skip {
                count += 1;
                true
            } else {
                raw_ips.push(frame.ip() as usize);
                count += 1;
                count < limit
            }
        });

        if count <= frame_skip {
            panic!(
                "Did not get at least `frame_skip` ({frame_skip}) frames in `capture_backtrace`; \
                this should not happen if the backtrace is properly calibrated."
            );
        }

        let mut hash: u64 = 0;
        for ip in &raw_ips {
            let (module_id, bias) = self.module_for_ip_cached(*ip);
            let svma = if module_id == UNKNOWN_MODULE_ID {
                *ip as u64
            } else {
                (*ip - bias) as u64
            };
            // Mix module id and svma so identical svmas in different
            // modules don't collide.
            hash = hash
                .rotate_left(13)
                ^ (svma.wrapping_mul(0x9E3779B97F4A7C15))
                ^ (module_id as u64);
            // Re-borrow staging each iteration; module_for_ip_cached
            // borrowed &mut self.
            let staging = self.staging.as_mut().expect("staging set above");
            staging.frames.push(CapturedFrame { module_id, svma });
        }

        if let Some(existing) = self.existing_traces.get(&hash) {
            // existing entry: return it, keeping the staging object for reuse.
            let staging = self.staging.as_mut().expect("staging set above");
            staging.frames.clear();
            existing.as_ptr() as u64
        } else {
            // no existing entry: take the staging object out of `self` and return it as a raw pointer
            let staged_box = self.staging.take().unwrap();
            // SAFETY: we ensure self.staging contains an initialized BumpBox on entry
            // to the function, which guarantees `raw_ptr` is non-null.
            let raw_ptr = unsafe { NonNull::new_unchecked(BumpBox::into_raw(staged_box)) };
            let _ = self.existing_traces.insert(hash, raw_ptr);
            raw_ptr.as_ptr() as u64
        }
    }

    /// Drain any modules discovered since the last call. Each
    /// [`ResolvedModule`] should be emitted into the operation stream as
    /// a `Custom` op with tag [`DEBUG_MODULE_TAG`] before any
    /// subsequent [`DEBUG_INFO_TAG`] op that references its `module_id`.
    ///
    /// After draining, the engine drops the module paths and retains
    /// only the bias needed for future captures on the same modules.
    pub fn drain_pending_modules(&mut self) -> Vec<ResolvedModule> {
        let mut out = Vec::with_capacity(self.pending_modules.len());
        for id in self.pending_modules.drain(..) {
            let info = &mut self.modules[id as usize];
            let path = info
                .path
                .take()
                .expect("pending module should still have its path");
            out.push(ResolvedModule {
                module_id: id,
                path: path.to_string_lossy().into_owned(),
                bias: info.bias as u64,
            });
        }
        out
    }

    /// Serialise each pending module as a separate msgpack blob, ready
    /// to be wrapped in `Custom { tag: DEBUG_MODULE_TAG, data }` ops.
    pub fn serialize_pending_modules(
        &mut self,
    ) -> Result<Vec<Vec<u8>>, rmp_serde::encode::Error> {
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
    pub fn serialize_backtrace(
        &self,
        bt_ref: u64,
    ) -> Result<Vec<u8>, rmp_serde::encode::Error> {
        let ptr = NonNull::new(bt_ref as *mut UnresolvedBacktrace)
            .expect("`bt_ref` should be nonzero");
        // SAFETY: `bt_ref` was returned by `capture_backtrace` on this
        // engine, whose bump arena is still alive (engine not dropped).
        let bt = unsafe { ptr.as_ref() };
        let payload = UnresolvedBacktracePayload {
            frames: bt.frames.iter().copied().collect(),
        };
        payload.serialize_msgpack()
    }
}

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
    /// table. `modules` maps `module_id` to the [`ResolvedModule`]
    /// announced earlier on the stream.
    ///
    /// Each module's on-disk binary is opened (at most once per call)
    /// with [`addr2line::Loader`]; one [`ResolvedSrcLocation`] is emitted
    /// per inlined frame returned by `find_frames`. Frames whose module
    /// is missing, whose file cannot be opened, or whose SVMA does not
    /// resolve, produce an `<unknown>` placeholder.
    pub fn from_unresolved(
        frames: &[CapturedFrame],
        modules: &HashMap<u32, ResolvedModule>,
    ) -> Self {
        let mut loaders: HashMap<u32, Option<Loader>> = HashMap::new();
        let mut out = Self {
            frames: Vec::with_capacity(frames.len()),
        };

        for f in frames {
            if f.module_id == UNKNOWN_MODULE_ID {
                out.frames.push(ResolvedSrcLocation::unknown());
                continue;
            }
            let Some(module) = modules.get(&f.module_id) else {
                out.frames.push(ResolvedSrcLocation::unknown());
                continue;
            };
            let loader = loaders
                .entry(f.module_id)
                .or_insert_with(|| Loader::new(&module.path).ok());
            let Some(loader) = loader.as_ref() else {
                out.frames.push(ResolvedSrcLocation::unknown());
                continue;
            };

            // addr2line expects a VMA in the binary's address space.
            // Our svma is module-load-relative (ip - dli_fbase). Add
            // the loader's relative_address_base to convert. On ELF PIE
            // builds this is 0; on Mach-O it's the lowest __TEXT vmaddr.
            let probe = f.svma.wrapping_add(loader.relative_address_base());

            let mut pushed = 0usize;
            if let Ok(mut iter) = loader.find_frames(probe) {
                while let Ok(Some(frame)) = iter.next() {
                    let function_name = frame
                        .function
                        .as_ref()
                        .and_then(|fn_| fn_.demangle().ok().map(|s| s.into_owned()))
                        .unwrap_or_else(|| "<unknown>".to_string());
                    let (file_name, line, column) = match frame.location {
                        Some(loc) => (
                            loc.file.map(|s| s.to_string()),
                            loc.line,
                            loc.column,
                        ),
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

    /// Helper: build a HashMap module table from the engine's pending
    /// drain, for use with `ResolvedBacktrace::from_unresolved`.
    fn drain_modules_as_map(engine: &mut BacktraceEngine) -> HashMap<u32, ResolvedModule> {
        engine
            .drain_pending_modules()
            .into_iter()
            .map(|m| (m.module_id, m))
            .collect()
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
        // At least one frame should have a real module id (not the sentinel).
        assert!(
            frames.iter().any(|f| f.module_id != UNKNOWN_MODULE_ID),
            "expected at least one frame with a known module"
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
            module_id: 7,
            path: "/tmp/example.so".to_string(),
            bias: 0x1234_5678,
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
    fn test_resolved_has_symbols() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 5);
        let frames = frames_of(bt_ref);
        let modules = drain_modules_as_map(&mut engine);
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
        let debug_info_available = modules.values().any(|m| {
            Loader::new(&m.path)
                .ok()
                .map(|l| {
                    frames.iter().any(|f| {
                        let probe = f.svma.wrapping_add(l.relative_address_base());
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
        let modules = drain_modules_as_map(&mut engine);
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
        let modules = drain_modules_as_map(&mut engine);

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
