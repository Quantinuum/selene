//! Backtrace metadata types for attaching source-location information to gates.
//!
//! [`UnresolvedBacktrace`] captures raw stack frames at the call site.
//! [`ResolvedBacktrace`] symbolises those frames into wire-format
//! [`ResolvedSrcLocation`] entries suitable for serialisation.

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

impl UnresolvedBacktrace {
    /// Capture a partial backtrace by skipping `n_skip` frames above the call
    /// site, then recording the next `n_capture` frames.
    pub fn create(n_skip: usize, n_capture: usize) -> Self {
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
