//! Backtrace metadata types for attaching source-location information to gates.
//!
//! [`UnresolvedBacktrace`] captures raw stack frames at the call site.
//! [`ResolvedBacktrace`] symbolises those frames into wire-format
//! [`ResolvedSrcLocation`] entries suitable for serialisation.

use core::ptr::NonNull;
use std::collections::{HashMap, HashSet};
use std::ffi::c_void;

use backtrace::{BacktraceFrame, BacktraceSymbol, Frame, Symbol, resolve, trace};
use bumpalo::{Bump, boxed::Box as BumpBox, collections::vec::Vec as BumpVec};

/// Magic tag used to identify `Custom` operations carrying backtrace metadata
/// in the selene output stream. Consumers should emit a `Custom` op with this
/// tag immediately before the corresponding gate op.
pub const DEBUG_INFO_TAG: usize = 0x6fcfc512e44136eb;

// to simplify the allocation story and improve performance, each frame of a backtrace
// is stored as a NonNull void pointer and later resolved using `backtrace::resolve`.
type FrameRef = NonNull<c_void>;
type BoxedBacktrace<'b> = BumpBox<'b, UnresolvedBacktrace<'b>>;

/// A partially-captured backtrace whose frames have not yet been symbolicated.
///
/// "Unresolved" refers to the backtrace frames, which are not symbolicated
/// until [`ResolvedBacktrace::from_unresolved`] is called.
struct UnresolvedBacktrace<'bump> {
    pub frames: BumpVec<'bump, FrameRef>,
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
        let staging = self
            .staging
            .get_or_insert_with(|| UnresolvedBacktrace::new_boxed(alloc_casted, n_capture));

        // capture the trace into the staging object
        let mut count = 0;
        let mut hash: u64 = 0;
        let limit = n_capture + frame_skip;
        trace(|frame: &Frame| {
            if count < frame_skip {
                count += 1;
                true
            } else {
                // TODO: more robust hash
                let ip = frame.ip();
                hash ^= ip as u64;
                // SAFETY: the instruction pointer returned by the library must be
                // non-null.
                staging.frames.push(unsafe { NonNull::new_unchecked(ip) });

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

        if let Some(existing) = self.existing_traces.get(&hash) {
            // existing entry: return it, keeping the staging object for reuse.
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
    fn from_symbol(sym: &Symbol) -> Self {
        Self {
            // an unresolvable symbol name should be rare in properly-generated
            // binaries, so we just insert a placeholder rather than making it an
            // Option type.
            function_name: sym
                .name()
                .map(|n| n.to_string())
                .unwrap_or("<unknown>".to_string()),
            file_name: sym
                .filename()
                .map(|p| p.to_str().expect("path should be UTF-8").to_string()),
            line: sym.lineno(),
            column: sym.colno(),
        }
    }
}

/// Wire-format representation of a resolved backtrace, ready for serialisation.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct ResolvedBacktrace {
    pub frames: Vec<ResolvedSrcLocation>,
}

impl ResolvedBacktrace {
    /// Symbolicate the frames in `input` and convert them to wire format.
    /// `input` must have been returned by a `BacktraceEngine` which has not
    /// yet been dropped.
    pub fn from_unresolved(bt_ref: u64) -> Self {
        let mut ptr =
            NonNull::new(bt_ref as *mut UnresolvedBacktrace).expect("`bt_ref` should be nonzero");
        // SAFETY: `bt_ref` must have been returned by a call to
        // `BacktraceEngine::capture_backtrace` on an engine which has not yet been
        // dropped.
        let unresolved = unsafe { ptr.as_mut() };
        let mut output = Self {
            frames: Vec::with_capacity(unresolved.frames.len()),
        };
        // TODO: could cache on ips if the library's caching is insufficient.
        for ip in unresolved.frames.iter() {
            // note that the closure may be called multiple times per frame if the
            // address points to an inlined function.
            resolve(ip.as_ptr(), |sym| {
                output.frames.push(ResolvedSrcLocation::from_symbol(sym))
            });
        }
        output
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

    #[test]
    fn test_create_captures_frames() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ptr = cap_synth_backtrace(&mut engine, 3) as *mut UnresolvedBacktrace;
        let mut bt_nn = NonNull::new(bt_ptr).unwrap();
        let bt = unsafe { bt_nn.as_mut() };

        assert!(
            !bt.frames.is_empty(),
            "expected at least one captured frame"
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
    fn test_resolved_has_symbols() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 5);
        let resolved = ResolvedBacktrace::from_unresolved(bt_ref);
        assert!(
            !resolved.frames.is_empty(),
            "expected at least one resolved frame"
        );
        assert!(
            resolved
                .frames
                .iter()
                .any(|f| f.function_name != "<unknown>"),
            "expected at least one frame with a function name"
        );
    }

    #[test]
    fn test_serialize_roundtrip() {
        let mut engine = BacktraceEngine::new(["selene_frame"], 0);
        let bt_ref = cap_synth_backtrace(&mut engine, 3);
        let resolved = ResolvedBacktrace::from_unresolved(bt_ref);
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

        // Each should resolve to at least one non-empty, symbolicated frame.
        let resolved_a = ResolvedBacktrace::from_unresolved(bt_a);
        let resolved_b = ResolvedBacktrace::from_unresolved(bt_b);

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
