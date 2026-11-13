//! Native LLVM builds described as immutable plans. This crate doesn't infer
//! program interfaces or choose compilation routes; callers describe those.
mod backend;
mod diagnostics;
mod executor;
#[cfg(feature = "python")]
mod python;
mod store;
mod toolchain;

use backend::Backend;
pub use diagnostics::{LinkDiagnostic, LinkError, LinkReference};
pub use executor::Executor;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::{path::Path, sync::Arc};
pub use store::{BuildResult, Store};
pub use toolchain::{CompileBuilder, LinkBuilder, LinkRuntime, Toolchain};

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error(transparent)]
    Link(#[from] LinkError),
    #[error("{0}")]
    Io(#[from] std::io::Error),
    #[error("{0}")]
    Json(#[from] serde_json::Error),
    #[error("{0}")]
    Invalid(String),
    #[error("LLVM backend error: {0}")]
    Backend(String),
    #[error("{operation} failed:\n{diagnostics}")]
    Operation {
        operation: String,
        diagnostics: String,
    },
}

pub(crate) fn digest(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ArtifactKind {
    Bitcode,
    Object,
    StaticLibrary,
    SharedLibrary,
    Executable,
}

/// An immutable snapshot. Paths are provenance, never a source to reread while
/// building. Names matter for archive diagnostics and shared-library loading.
#[derive(Clone, Debug)]
pub struct Artifact {
    pub(crate) kind: ArtifactKind,
    pub(crate) bytes: Arc<Vec<u8>>,
    pub(crate) digest: String,
    pub(crate) name: String,
}

impl Artifact {
    pub fn from_bytes(kind: ArtifactKind, bytes: impl Into<Vec<u8>>) -> Self {
        let bytes = bytes.into();
        Self {
            kind,
            digest: digest(&bytes),
            bytes: Arc::new(bytes),
            name: match kind {
                ArtifactKind::Bitcode => "module.bc",
                ArtifactKind::Object => "object.o",
                ArtifactKind::StaticLibrary => "library.a",
                ArtifactKind::SharedLibrary => "library.so",
                ArtifactKind::Executable => "program",
            }
            .into(),
        }
    }
    pub fn from_path(kind: ArtifactKind, path: impl AsRef<Path>) -> Result<Self> {
        let path = path.as_ref();
        let artifact = Self::from_bytes(kind, std::fs::read(path)?);
        let name = path
            .file_name()
            .and_then(|n| n.to_str())
            .ok_or_else(|| Error::Invalid("Artifact filename must be valid UTF-8".into()))?
            .to_owned();
        artifact.with_name(name)
    }
    /// Give an in-memory artifact a filename for diagnostics and storage.
    pub fn with_name(mut self, name: impl Into<String>) -> Result<Self> {
        let name = name.into();
        if name.is_empty()
            || matches!(name.as_str(), "." | "..")
            || name.contains(['/', '\\'])
            || name.chars().any(char::is_control)
            || Path::new(&name).file_name() != Some(std::ffi::OsStr::new(&name))
        {
            return Err(Error::Invalid(
                "Artifact name must be a filename without path separators or control characters"
                    .into(),
            ));
        }
        self.name = name;
        Ok(self)
    }
    pub fn name(&self) -> &str {
        &self.name
    }
    pub fn kind(&self) -> ArtifactKind {
        self.kind
    }
    pub fn digest(&self) -> &str {
        &self.digest
    }
    pub fn bytes(&self) -> &[u8] {
        &self.bytes
    }
    pub fn symbols(&self, toolchain: &Toolchain) -> Result<serde_json::Value> {
        toolchain.inspect(self)
    }
    pub fn copy_to(&self, path: impl AsRef<Path>) -> Result<()> {
        std::fs::write(path.as_ref(), self.bytes())?;
        if self.kind == ArtifactKind::Executable {
            store::executable(path.as_ref())?;
        }
        Ok(())
    }
    pub(crate) fn identity(&self) -> serde_json::Value {
        serde_json::json!({"kind": self.kind, "digest": self.digest, "name": self.name})
    }
}

#[derive(Clone, Debug)]
pub enum Input {
    Artifact(Artifact),
    Plan(Plan),
}
impl From<Artifact> for Input {
    fn from(a: Artifact) -> Self {
        Self::Artifact(a)
    }
}
impl From<Plan> for Input {
    fn from(p: Plan) -> Self {
        Self::Plan(p)
    }
}
impl Input {
    pub fn kind(&self) -> ArtifactKind {
        match self {
            Self::Artifact(a) => a.kind,
            Self::Plan(p) => p.kind(),
        }
    }
}

#[derive(Clone)]
pub struct Plan(pub(crate) Arc<Node>);
impl std::fmt::Debug for Plan {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.describe())
    }
}

pub(crate) struct Node {
    pub backend: Arc<Backend>,
    pub target: String,
    pub operation: Operation,
}

pub(crate) enum Operation {
    Compile {
        source: Artifact,
        optimisation: u8,
        retarget: bool,
    },
    Link {
        inputs: Vec<Input>,
        arguments: Vec<LinkArg>,
        kind: ArtifactKind,
        cacheable: bool,
    },
}
#[derive(Clone)]
pub(crate) enum LinkArg {
    Text(String),
    File(Artifact),
    Dependency(Artifact),
    Input(usize),
    Output,
}

impl Plan {
    pub fn kind(&self) -> ArtifactKind {
        match &self.0.operation {
            Operation::Compile { .. } => ArtifactKind::Object,
            Operation::Link { kind, .. } => *kind,
        }
    }
    /// A versioned description containing identities rather than copies of
    /// potentially large inputs. Store records preserve this for provenance.
    pub fn describe(&self) -> serde_json::Value {
        match &self.0.operation {
            Operation::Compile {
                source,
                optimisation,
                retarget,
            } => serde_json::json!({
                "schema": 1, "operation": "compile", "backend": self.0.backend.identity,
                "implementation": env!("SELENE_TOOLCHAIN_IMPLEMENTATION"),
                "target": self.0.target, "source": source.identity(), "optimisation": optimisation,
                "retarget": retarget,
            }),
            Operation::Link {
                inputs,
                arguments,
                kind,
                cacheable,
            } => serde_json::json!({
                "schema": 1, "operation": "link", "backend": self.0.backend.identity,
                "implementation": env!("SELENE_TOOLCHAIN_IMPLEMENTATION"),
                "target": self.0.target, "kind": kind, "cacheable": cacheable,
                "inputs": inputs.iter().map(|input| match input {
                    Input::Artifact(a) => a.identity(), Input::Plan(p) => p.describe(),
                }).collect::<Vec<_>>(),
                "arguments": arguments.iter().map(|a| match a {
                    LinkArg::Text(s) => serde_json::json!({"argument": s}),
                    LinkArg::File(a) | LinkArg::Dependency(a) => a.identity(), LinkArg::Input(i) => serde_json::json!({"input": i}),
                    LinkArg::Output => serde_json::json!({"output": true}),
                }).collect::<Vec<_>>(),
            }),
        }
    }
}

pub fn native_target() -> &'static str {
    #[cfg(all(target_os = "linux", target_arch = "x86_64"))]
    {
        "x86_64-unknown-linux-gnu"
    }
    #[cfg(all(target_os = "linux", target_arch = "aarch64"))]
    {
        "aarch64-unknown-linux-gnu"
    }
    #[cfg(all(target_os = "macos", target_arch = "x86_64"))]
    {
        "x86_64-apple-macosx11.0.0"
    }
    #[cfg(all(target_os = "macos", target_arch = "aarch64"))]
    {
        "aarch64-apple-macosx11.0.0"
    }
    #[cfg(all(target_os = "windows", target_arch = "x86_64"))]
    {
        "x86_64-w64-windows-gnu"
    }
}

pub(crate) fn path_string(path: &Path) -> Result<String> {
    path.to_str()
        .map(str::to_owned)
        .ok_or_else(|| Error::Invalid(format!("Path is not UTF-8: {}", path.display())))
}

macro_rules! artifact_type {
    ($name:ident, $kind:ident) => {
        #[derive(Clone, Debug)]
        pub struct $name(Artifact);
        impl $name {
            pub fn from_path(path: impl AsRef<Path>) -> Result<Self> {
                Ok(Self(Artifact::from_path(ArtifactKind::$kind, path)?))
            }
            pub fn from_bytes(bytes: impl Into<Vec<u8>>) -> Self {
                Self(Artifact::from_bytes(ArtifactKind::$kind, bytes))
            }
            pub fn with_name(self, name: impl Into<String>) -> Result<Self> {
                Ok(Self(self.0.with_name(name)?))
            }
            pub fn name(&self) -> &str {
                self.0.name()
            }
            pub fn digest(&self) -> &str {
                self.0.digest()
            }
            pub fn bytes(&self) -> &[u8] {
                self.0.bytes()
            }
            pub fn copy_to(&self, path: impl AsRef<Path>) -> Result<()> {
                self.0.copy_to(path)
            }
        }
        impl From<$name> for Artifact {
            fn from(value: $name) -> Self {
                value.0
            }
        }
        impl From<$name> for Input {
            fn from(value: $name) -> Self {
                Self::Artifact(value.0)
            }
        }
    };
}
artifact_type!(Bitcode, Bitcode);
artifact_type!(ObjectFile, Object);
artifact_type!(StaticLibrary, StaticLibrary);
artifact_type!(SharedLibrary, SharedLibrary);
artifact_type!(Executable, Executable);

#[derive(Clone, Debug, Deserialize)]
pub struct ObjectSymbols {
    pub defined_symbols: std::collections::BTreeSet<String>,
    pub undefined_symbols: std::collections::BTreeSet<String>,
}
#[derive(Clone, Debug, Deserialize)]
pub struct ModuleSymbols {
    pub defined_functions: std::collections::BTreeSet<String>,
    pub declared_functions: std::collections::BTreeSet<String>,
}
impl ObjectFile {
    pub fn symbols(&self, toolchain: &Toolchain) -> Result<ObjectSymbols> {
        Ok(serde_json::from_value(toolchain.inspect(&self.0)?)?)
    }
}
impl Bitcode {
    pub fn functions(&self, toolchain: &Toolchain) -> Result<ModuleSymbols> {
        Ok(serde_json::from_value(toolchain.inspect(&self.0)?)?)
    }
}
