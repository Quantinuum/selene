//! Backtrace metadata types for attaching source-location information to gates.
//!
//! [`UnresolvedBacktrace`] captures raw stack frames at the call site.
//! [`ResolvedBacktrace`] symbolises those frames into wire-format
//! [`ResolvedSrcLocation`] entries suitable for serialisation.

use core::ptr::NonNull;
use std::collections::HashMap;
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

/// Class which manages backtraces, including efficient allocation and deduplication.
#[derive(Default)]
pub struct BacktraceEngine<'bump> {
    /// Map from backtrace hash to existing backtraces
    /// The key is the hash itself - the lookup is only used when a new backtrace is
    /// constructed, to perform deduplication. We create the hash as part of
    /// constructing it rather than implementing Hash.
    existing_traces: HashMap<u64, NonNull<UnresolvedBacktrace<'bump>>>,
    /// Number of frames between the call site of `capture_backtrace` and the first
    /// saved frame (which should be the QIS call site in the user program).
    /// Automatically set the first time a backtrace is captured.
    frame_skip: Option<usize>,
    /// Bump allocator which provides backing memory
    allocator: Bump,
    /// Landing zone for trace data (see capture_backtrace)  
    staging: Option<BoxedBacktrace<'bump>>,
}

impl<'bump> BacktraceEngine<'bump> {
    // TODO: just use a proper regex...
    /// We look for the Selene C API to determine the number of frames to skip.
    /// The C API is chosen because:
    /// - names are more greppable than the QIS API
    /// - both QIS and C API are external interfaces that cannot be inlined,
    ///   so as long as the former always calls the latter directly the frame
    ///   relationship is well-known.
    fn is_c_api_sym(sym: &BacktraceSymbol) -> bool {
        let name_obj = sym
            .name()
            .expect("symbols passed to this function should be symbolicated");
        // use Display to get the demangled name.
        let name = format!("{name_obj}");

        // Functions in the C API do not have path separators.
        if name.contains(":") {
            return false;
        }

        // remove the _ prepended by macos if present
        // TODO: compile-time config?
        let name_canonical = name
            .strip_prefix("_") // MacOS prepends an extra '_'
            .or_else(|| Some(&name))
            .unwrap();

        // functions in the C API start with 'selene_', and are not followed by `runtime`.
        if let Some(next_component) = name_canonical.strip_prefix("selene_") {
            !next_component.starts_with("runtime")
        } else {
            false
        }
    }

    /// Number of frames to skip past the Selene C API
    const SKIP_PAST_C_API: usize = 2;
    const MAX_FRAMES_TO_SEARCH: usize = 10;

    /// Get the frame skip count, finding it if it is not yet set.
    #[inline(never)]
    fn get_frame_skip(&mut self) -> usize {
        if let Some(skip_count) = self.frame_skip {
            skip_count
        } else {
            let mut skip_count = 0;
            backtrace::trace(|abstract_frame| {
                let mut frame: BacktraceFrame = abstract_frame.clone().into();
                frame.resolve();
                let syms = frame.symbols();
                for (i, sym) in syms.iter().enumerate() {
                    if Self::is_c_api_sym(sym) {
                        // must be the outermost symbol in the frame (not inlined)
                        if i != syms.len() - 1 {
                            panic!("C API frame was inlined, or detection function is wrong")
                        }
                        return false; // we have found the anchor frame
                    }
                }

                // frame not found, continue until we hit the max
                skip_count += 1;
                skip_count < Self::MAX_FRAMES_TO_SEARCH
            });

            if skip_count == Self::MAX_FRAMES_TO_SEARCH {
                panic!(
                    "Could not find anchor frame for debug backtrace within {} frames",
                    Self::MAX_FRAMES_TO_SEARCH
                );
            }

            // adjust for this function's frame
            skip_count -= 1;
            // adjust to skip callers above the selene C API
            skip_count += Self::SKIP_PAST_C_API;

            self.frame_skip = Some(skip_count);
            skip_count
        }
    }

    pub fn capture_backtrace(&mut self, n_capture: usize) -> u64 {
        let frame_skip = self.get_frame_skip();
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
                dbg!(ip);
                hash ^= ip as u64;
                // SAFETY: the instruction pointer returned by the library must be
                // non-null
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
        dbg!(hash);

        if let Some(existing) = self.existing_traces.get(&hash) {
            // existing entry: return it, keeping the staging object for reuse.
            staging.frames.clear();
            existing.as_ptr() as u64
        } else {
            // no existing entry: take the staging object out of `self` and return it as a raw pointer
            let staged_box = self.staging.take().unwrap();
            BumpBox::into_raw(staged_box) as u64
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
    fn pseudo(engine: &mut BacktraceEngine, n_cap: usize) -> u64 {
        engine.capture_backtrace(n_cap)
    }

    // this function should match the rules in `is_c_api_sym()`.
    //
    // no_mangle is used only to ensure the name is preserved -
    // this module is not intended for FFI use.
    #[inline(never)]
    #[unsafe(no_mangle)]
    fn selene_pseudo(engine: *mut BacktraceEngine, n_cap: usize) -> u64 {
        let eref = unsafe { &mut *engine };
        pseudo(eref, n_cap)
    }

    #[inline(never)]
    fn cap_synth_backtrace(engine: &mut BacktraceEngine, n_cap: usize) -> u64 {
        selene_pseudo(engine as *mut BacktraceEngine, n_cap)
    }

    #[test]
    fn test_create_captures_frames() {
        let mut engine = BacktraceEngine::default();
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
        let mut engine = BacktraceEngine::default();
        let bt1 = cap_synth_backtrace(&mut engine, 1);
        let bt2 = cap_synth_backtrace(&mut engine, 1);
        assert!(bt1 == bt2, "expected backtraces to be deduplicated");
    }

    #[test]
    fn test_resolved_has_symbols() {
        let mut engine = BacktraceEngine::default();
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
        let mut engine = BacktraceEngine::default();
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
}
