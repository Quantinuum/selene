//! Backtrace metadata types for attaching source-location information to gates.
//!
//! [`UnresolvedBacktrace`] captures raw stack frames at the call site.
//! [`ResolvedBacktrace`] symbolises those frames into wire-format
//! [`ResolvedSrcLocation`] entries suitable for serialisation.

use std::sync::OnceLock;

use backtrace::{BacktraceFrame, BacktraceSymbol};

/// Magic tag used to identify `Custom` operations carrying backtrace metadata
/// in the selene output stream. Consumers should emit a `Custom` op with this
/// tag immediately before the corresponding gate op.
pub const DEBUG_INFO_TAG: usize = 0x6fcfc512e44136eb;

/// A partially-captured backtrace whose frames have not yet been symbolicated.
///
/// "Unresolved" refers to the backtrace frames, which are not symbolicated
/// until [`ResolvedBacktrace::from_unresolved`] is called.
pub struct UnresolvedBacktrace {
    pub frames: Vec<BacktraceFrame>,
}

/// Number of internal frames to skip to find a gate call site. Initialized the first
/// time that a backtrace is created. We use OnceLock rather than LazyLock to avoid
/// using a closure to calibrate the backtrace.
static BT_FRAME_SKIP: OnceLock<usize> = OnceLock::new();

impl UnresolvedBacktrace {
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
    fn get_frame_skip() -> usize {
        if let Some(skip_count) = BT_FRAME_SKIP.get() {
            *skip_count
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

            // it is possible for multiple callers to race on setting this value in a
            // multithreaded program. only one will succeed. this is fine, they should
            // resolve the same value anyway.
            if BT_FRAME_SKIP.set(skip_count).is_err() {
                // if we lost the race, opportunistically validate that we resolved the
                // same value.
                let oth_count = BT_FRAME_SKIP.get().unwrap();
                assert!(
                    skip_count != *oth_count,
                    "threads resolved different backtrace skip counts: {skip_count} != {oth_count}"
                );
            }
            skip_count
        }
    }

    /// Capture a partial backtrace at a gate call site (specifically a QIS interface).
    /// `n_capture` is the number of frames to capture, with the first frame being the QIS
    /// call.
    pub fn create(n_capture: usize) -> Self {
        let n_skip = UnresolvedBacktrace::get_frame_skip();
        let mut frames = Vec::with_capacity(n_capture);
        let mut skip_ctr = 0;
        backtrace::trace(|frame| {
            if skip_ctr < n_skip {
                skip_ctr += 1;
                true
            } else {
                frames.push(frame.clone().into());
                frames.len() < n_capture
            }
        });
        Self { frames }
    }
}

/// Wire-format representation of a single symbolicated backtrace frame.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct ResolvedSrcLocation {
    pub function_name: String,
    pub file_name: String,
    /// Line number as a string; `"<none>"` when unavailable.
    pub line: String,
    /// Column number as a string; `"<none>"` when unavailable.
    pub column: String,
}

impl ResolvedSrcLocation {
    fn from_symbol(sym: &BacktraceSymbol) -> Self {
        let null_str = "<none>".to_string();
        Self {
            function_name: sym
                .name()
                .map(|n| n.to_string())
                .unwrap_or_else(|| null_str.clone()),
            file_name: sym
                .filename()
                .map(|p| p.to_str().expect("path should be UTF-8").to_string())
                .unwrap_or_else(|| null_str.clone()),
            line: sym
                .lineno()
                .map(|l| l.to_string())
                .unwrap_or_else(|| null_str.clone()),
            column: sym.colno().map(|c| c.to_string()).unwrap_or(null_str),
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
    pub fn from_unresolved(input: &mut UnresolvedBacktrace) -> Self {
        let mut output = Self {
            frames: Vec::with_capacity(input.frames.len()),
        };
        for frame in input.frames.iter_mut() {
            frame.resolve();
            output
                .frames
                .extend(frame.symbols().iter().map(ResolvedSrcLocation::from_symbol));
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

    #[test]
    fn test_create_captures_frames() {
        let bt = UnresolvedBacktrace::create(0, 3);
        assert!(
            !bt.frames.is_empty(),
            "expected at least one captured frame"
        );
    }

    #[test]
    fn test_resolved_has_symbols() {
        let mut bt = UnresolvedBacktrace::create(0, 5);
        let resolved = ResolvedBacktrace::from_unresolved(&mut bt);
        assert!(
            !resolved.frames.is_empty(),
            "expected at least one resolved frame"
        );
        assert!(
            resolved.frames.iter().any(|f| f.function_name != "<none>"),
            "expected at least one frame with a function name"
        );
    }

    #[test]
    fn test_serialize_roundtrip() {
        let mut bt = UnresolvedBacktrace::create(0, 3);
        let resolved = ResolvedBacktrace::from_unresolved(&mut bt);
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
