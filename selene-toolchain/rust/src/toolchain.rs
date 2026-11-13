use crate::{
    Artifact, ArtifactKind, Error, Input, LinkArg, Node, Operation, Plan, Result, backend::Backend,
    native_target, path_string,
};
use serde::Deserialize;
use std::{
    path::{Path, PathBuf},
    sync::Arc,
};

#[derive(Clone)]
pub struct Toolchain {
    pub(crate) backend: Arc<Backend>,
    runtime: Option<LinkRuntime>,
}
/// Startup objects, compiler helpers and platform libraries supplied separately
/// from the LLVM development prefix used to build this crate.
#[derive(Clone)]
pub struct LinkRuntime {
    root: PathBuf,
}
impl LinkRuntime {
    pub fn from_directory(root: impl AsRef<Path>) -> Result<Self> {
        let root = root.as_ref().canonicalize()?;
        if !root.join("link.json").is_file() || !root.join("runtime").is_dir() {
            return Err(Error::Invalid(
                "A link runtime requires link.json and a runtime directory".into(),
            ));
        }
        Ok(Self { root })
    }
}
#[derive(Deserialize)]
struct Runtime {
    system: String,
    machine: String,
    before: Vec<String>,
    after: Vec<String>,
    libraries: Vec<String>,
}

impl Toolchain {
    /// Use the LLVM/LLD implementation linked into this crate by Cargo.
    pub fn new() -> Result<Self> {
        Ok(Self {
            backend: Arc::new(Backend::linked()?),
            runtime: None,
        })
    }
    pub fn with_runtime(mut self, runtime: LinkRuntime) -> Self {
        self.runtime = Some(runtime);
        self
    }
    /// Convenience for the runtime inputs packaged in a Python wheel. This
    /// directory supplies link inputs, not an LLVM backend to load.
    pub fn from_directory(root: impl AsRef<Path>) -> Result<Self> {
        Ok(Self::new()?.with_runtime(LinkRuntime::from_directory(root)?))
    }
    pub fn version(&self) -> Result<String> {
        Ok(
            String::from_utf8_lossy(&self.backend.run("version", &[], &serde_json::Value::Null)?)
                .into_owned(),
        )
    }
    pub fn inspect(&self, artifact: &Artifact) -> Result<serde_json::Value> {
        let operation =
            match artifact.kind {
                ArtifactKind::Bitcode => "inspect",
                ArtifactKind::Object | ArtifactKind::SharedLibrary | ArtifactKind::Executable => {
                    "inspect-object"
                }
                ArtifactKind::StaticLibrary => return Err(Error::Invalid(
                    "Archive inspection must preserve member boundaries; it isn't implemented yet"
                        .into(),
                )),
            };
        Ok(serde_json::from_slice(&self.backend.run(
            operation,
            artifact.bytes(),
            &serde_json::json!({"name": artifact.name()}),
        )?)?)
    }
    pub fn compile(&self, source: impl Into<Artifact>) -> CompileBuilder {
        CompileBuilder {
            toolchain: self.clone(),
            source: source.into(),
            optimisation: 0,
            retarget: false,
        }
    }
    pub fn link_executable(&self) -> LinkBuilder {
        self.link(ArtifactKind::Executable)
    }
    pub fn link_shared_library(&self) -> LinkBuilder {
        self.link(ArtifactKind::SharedLibrary)
    }
    fn link(&self, kind: ArtifactKind) -> LinkBuilder {
        LinkBuilder {
            toolchain: self.clone(),
            inputs: vec![],
            system: vec![],
            flags: vec![],
            search: vec![],
            kind,
        }
    }
}

pub struct CompileBuilder {
    toolchain: Toolchain,
    source: Artifact,
    optimisation: u8,
    retarget: bool,
}
impl CompileBuilder {
    /// Explicitly replace target metadata. The caller must know that its IR
    /// doesn't contain incompatible target-dependent assumptions.
    pub fn retarget(mut self, enabled: bool) -> Self {
        self.retarget = enabled;
        self
    }
    pub fn optimisation(mut self, level: u8) -> Self {
        self.optimisation = level;
        self
    }
    pub fn plan(self) -> Result<Plan> {
        if self.source.kind != ArtifactKind::Bitcode {
            return Err(Error::Invalid(
                "Compilation requires LLVM IR or bitcode".into(),
            ));
        }
        if self.optimisation > 3 {
            return Err(Error::Invalid(
                "Optimisation must be between 0 and 3".into(),
            ));
        }
        // Validate input now so a compiler error isn't mistaken for a cache miss.
        self.toolchain.inspect(&self.source)?;
        Ok(Plan(Arc::new(Node {
            backend: self.toolchain.backend,
            target: native_target().into(),
            operation: Operation::Compile {
                source: self.source,
                optimisation: self.optimisation,
                retarget: self.retarget,
            },
        })))
    }
}

pub struct LinkBuilder {
    toolchain: Toolchain,
    inputs: Vec<Input>,
    system: Vec<String>,
    flags: Vec<String>,
    search: Vec<PathBuf>,
    kind: ArtifactKind,
}
impl LinkBuilder {
    pub fn object(mut self, input: impl Into<Input>) -> Self {
        self.inputs.push(input.into());
        self
    }
    pub fn library(mut self, library: impl Into<Artifact>) -> Self {
        self.inputs.push(Input::Artifact(library.into()));
        self
    }
    pub fn system_library(mut self, name: impl Into<String>) -> Self {
        self.system.push(name.into());
        self
    }
    /// An escape hatch for existing callers. These arguments can name hidden
    /// inputs, so plans using them bypass result caching until modelled explicitly.
    pub fn link_flag(mut self, flag: impl Into<String>) -> Self {
        self.flags.push(flag.into());
        self
    }
    pub fn search_directory(mut self, path: impl Into<PathBuf>) -> Self {
        self.search.push(path.into());
        self
    }
    pub fn plan(self) -> Result<Plan> {
        if self.inputs.is_empty() {
            return Err(Error::Invalid(
                "Linking requires at least one object or library".into(),
            ));
        }
        for input in &self.inputs {
            if !matches!(
                input.kind(),
                ArtifactKind::Object | ArtifactKind::StaticLibrary | ArtifactKind::SharedLibrary
            ) {
                return Err(Error::Invalid(
                    "Link inputs must be objects, static libraries or shared libraries".into(),
                ));
            }
            if let Input::Artifact(artifact) = input
                && artifact.kind == ArtifactKind::StaticLibrary
                && !artifact.bytes().starts_with(b"!<arch>\n")
            {
                return Err(Error::Invalid(
                    "Static libraries must be self-contained archives; thin archives and linker scripts are not supported".into(),
                ));
            }
            if let Input::Artifact(artifact) = input
                && artifact.kind != ArtifactKind::StaticLibrary
            {
                let metadata = self.toolchain.inspect(artifact)?;
                let triple = metadata["target"].as_str().unwrap_or("");
                let architecture = triple.split('-').next().unwrap_or("");
                let expected = native_target().split('-').next().unwrap_or("");
                let compatible =
                    architecture == expected || (architecture == "arm64" && expected == "aarch64");
                let format = metadata["format"].as_str().unwrap_or("");
                let os_matches = format
                    == if cfg!(windows) {
                        "COFF"
                    } else if cfg!(target_os = "macos") {
                        "MachO"
                    } else {
                        "ELF"
                    };
                if !compatible || !os_matches {
                    return Err(Error::Invalid(format!(
                        "Object target {triple} is incompatible with {}",
                        native_target()
                    )));
                }
            }
        }
        let root = &self.toolchain.runtime.as_ref()
            .ok_or_else(|| Error::Invalid("Linking requires runtime inputs; configure Toolchain::with_runtime(LinkRuntime::from_directory(...))".into()))?.root;
        let config: Runtime = serde_json::from_slice(&std::fs::read(root.join("link.json"))?)?;
        let expected_system = if cfg!(windows) {
            "Windows"
        } else if cfg!(target_os = "macos") {
            "Darwin"
        } else {
            "Linux"
        };
        if config.system != expected_system || !native_target().starts_with(&config.machine) {
            return Err(Error::Invalid(
                "Runtime distribution does not match the native platform".into(),
            ));
        }
        let runtime = root.join("runtime");
        let mut directories = vec![runtime.clone()];
        directories.extend(self.search.iter().cloned());
        let mut args = vec![];
        let text = |args: &mut Vec<LinkArg>, value: &str| args.push(LinkArg::Text(value.into()));
        text(
            &mut args,
            if cfg!(target_os = "macos") {
                "ld64.lld"
            } else {
                "ld.lld"
            },
        );
        text(&mut args, "-o");
        args.push(LinkArg::Output);
        if cfg!(target_os = "macos") {
            text(&mut args, "-arch");
            text(
                &mut args,
                if config.machine == "aarch64" {
                    "arm64"
                } else {
                    "x86_64"
                },
            );
            for value in ["-platform_version", "macos", "11.0", "11.0"] {
                text(&mut args, value);
            }
            if self.kind == ArtifactKind::SharedLibrary {
                text(&mut args, "-dylib");
                text(&mut args, "-install_name");
                text(&mut args, "@rpath/library.dylib");
            }
        } else if cfg!(windows) {
            for value in ["-m", "i386pep", "--subsystem", "console"] {
                text(&mut args, value);
            }
            if self.kind == ArtifactKind::SharedLibrary {
                text(&mut args, "--shared");
                // LLD's default DLL entry point uses MSVC's spelling, but
                // our MinGW startup object defines DllMainCRTStartup.
                text(&mut args, "--entry");
                text(&mut args, "DllMainCRTStartup");
            }
        } else {
            text(
                &mut args,
                if self.kind == ArtifactKind::SharedLibrary {
                    "-shared"
                } else {
                    "-pie"
                },
            );
            text(&mut args, "--eh-frame-hdr");
            if self.kind == ArtifactKind::Executable {
                let interpreter = linux_interpreter()?;
                // The loader is selected by the host, and its contents are an
                // explicit dependency even though LLD only embeds its path.
                args.push(LinkArg::Text("--dynamic-linker".into()));
                args.push(LinkArg::Text(path_string(&interpreter)?));
                let loader = Artifact::from_path(ArtifactKind::SharedLibrary, interpreter)?;
                // A key-only argument records the loader without linking it.
                // LinkArg::Dependency is handled by the store separately.
                args.push(LinkArg::Dependency(loader));
            }
        }
        // Raw flags and object directives can ask LLD for additional libraries.
        // The explicitly resolved inputs below don't need a search path, but
        // these requests still need access to the bundled import libraries.
        for directory in std::iter::once(&runtime).chain(&self.search) {
            let path = path_string(directory)?;
            #[cfg(windows)]
            let path = normalise_library_search_path(&path);
            text(&mut args, &format!("-L{path}"));
        }
        if !cfg!(target_os = "macos") {
            for name in &config.before {
                if self.kind == ArtifactKind::SharedLibrary && name == "Scrt1.o" {
                    continue;
                }
                let name = if self.kind == ArtifactKind::SharedLibrary && name == "crt2.o" {
                    "dllcrt2.o"
                } else {
                    name
                };
                args.push(LinkArg::File(Artifact::from_path(
                    ArtifactKind::Object,
                    runtime.join(name),
                )?));
            }
            text(&mut args, "--start-group");
        }
        for i in 0..self.inputs.len() {
            args.push(LinkArg::Input(i));
        }
        let mut flags = vec![];
        for flag in &self.flags {
            if let Some(rest) = flag.strip_prefix("-Wl,") {
                flags.extend(rest.split(',').map(str::to_owned));
            } else {
                flags.push(flag.clone());
            }
        }
        for flag in &flags {
            if flag.contains('\0')
                || flag.starts_with('@')
                || flag == "-o"
                || flag.starts_with("--output")
                || flag.starts_with("-o=")
            {
                return Err(Error::Invalid(
                    "Output and response-file arguments must be supplied through the build API"
                        .into(),
                ));
            }
            text(&mut args, flag);
        }
        let libraries: Vec<String> = if cfg!(target_os = "macos") {
            vec!["-lSystem".into()]
        } else {
            config.libraries
        };
        for name in self
            .system
            .iter()
            .map(|name| format!("-l{name}"))
            .chain(libraries)
        {
            if !name.starts_with("-l") {
                return Err(Error::Invalid(format!(
                    "Unsupported runtime argument: {name}"
                )));
            }
            args.push(LinkArg::File(resolve_library(&name[2..], &directories)?));
        }
        if cfg!(target_os = "linux") {
            args.push(LinkArg::File(Artifact::from_path(
                ArtifactKind::StaticLibrary,
                runtime.join("libc_nonshared.a"),
            )?));
        }
        if !cfg!(target_os = "macos") {
            text(&mut args, "--end-group");
            for name in config.after {
                args.push(LinkArg::File(Artifact::from_path(
                    ArtifactKind::Object,
                    runtime.join(name),
                )?));
            }
        }
        Ok(Plan(Arc::new(Node {
            backend: self.toolchain.backend,
            target: native_target().into(),
            operation: Operation::Link {
                inputs: self.inputs,
                arguments: args,
                kind: self.kind,
                cacheable: self.flags.is_empty() && self.search.is_empty(),
            },
        })))
    }
}

#[cfg(any(windows, test))]
fn normalise_library_search_path(path: &str) -> String {
    // Rust's canonical paths use Windows' verbatim prefix. LLD can open an
    // explicit file through that path, but its MinGW library search fails
    // when it appends filenames to a verbatim directory. Give that search
    // an ordinary absolute path, preserving UNC server and share names.
    if let Some(share) = path.strip_prefix(r"\\?\UNC\") {
        format!(r"\\{share}")
    } else if let Some(drive) = path.strip_prefix(r"\\?\")
        && drive.as_bytes().get(1) == Some(&b':')
    {
        drive.into()
    } else {
        path.into()
    }
}

fn resolve_library(name: &str, directories: &[PathBuf]) -> Result<Artifact> {
    if name.is_empty() || name.contains(['/', '\\', '\0']) {
        return Err(Error::Invalid("Invalid system library name".into()));
    }
    for directory in directories {
        for suffix in [".so", ".dylib", ".a", ".tbd"] {
            let path = directory.join(format!("lib{name}{suffix}"));
            if path.is_file() {
                return Artifact::from_path(
                    if suffix == ".so" || suffix == ".dylib" {
                        ArtifactKind::SharedLibrary
                    } else {
                        ArtifactKind::StaticLibrary
                    },
                    path,
                );
            }
        }
    }
    #[cfg(target_os = "linux")]
    {
        let soname = match name {
            "c" => "libc.so.6",
            "m" => "libm.so.6",
            "pthread" => "libpthread.so.0",
            "dl" => "libdl.so.2",
            "rt" => "librt.so.1",
            "resolv" => "libresolv.so.2",
            "util" => "libutil.so.1",
            "anl" => "libanl.so.1",
            _ => {
                return Err(Error::Invalid(format!(
                    "No explicit library supplied for {name}"
                )));
            }
        };
        #[repr(C)]
        struct LinkMap {
            address: usize,
            name: *const std::ffi::c_char,
        }
        // SAFETY: dlinfo writes a pointer to the loaded library's link-map.
        // Keep the handle alive until its filename has been copied.
        unsafe {
            let name = std::ffi::CString::new(soname).unwrap();
            let handle = libc::dlopen(name.as_ptr(), libc::RTLD_NOW | libc::RTLD_LOCAL);
            if handle.is_null() {
                return Err(Error::Invalid(format!(
                    "Cannot load system library {soname}"
                )));
            }
            let mut map: *mut LinkMap = std::ptr::null_mut();
            let status = libc::dlinfo(
                handle,
                libc::RTLD_DI_LINKMAP,
                (&mut map as *mut *mut LinkMap).cast(),
            );
            let result = if status == 0 && !map.is_null() && !(*map).name.is_null() {
                let path = std::ffi::CStr::from_ptr((*map).name)
                    .to_string_lossy()
                    .into_owned();
                Artifact::from_path(ArtifactKind::SharedLibrary, path)
            } else {
                Err(Error::Invalid(format!(
                    "Cannot locate system library {soname}"
                )))
            };
            libc::dlclose(handle);
            result
        }
    }
    #[cfg(not(target_os = "linux"))]
    Err(Error::Invalid(format!(
        "No explicit library supplied for {name}"
    )))
}

#[cfg(target_os = "linux")]
fn linux_interpreter() -> Result<PathBuf> {
    use std::io::{Read, Seek, SeekFrom};
    let mut file = std::fs::File::open(std::env::current_exe()?)?;
    let mut header = [0; 64];
    file.read_exact(&mut header)?;
    if &header[..6] != b"\x7fELF\x02\x01" {
        return Err(Error::Invalid(
            "Expected a 64-bit little-endian host executable".into(),
        ));
    }
    let offset = u64::from_le_bytes(header[32..40].try_into().unwrap());
    let size = u16::from_le_bytes(header[54..56].try_into().unwrap()) as u64;
    let count = u16::from_le_bytes(header[56..58].try_into().unwrap()) as u64;
    for i in 0..count {
        file.seek(SeekFrom::Start(offset + i * size))?;
        let mut entry = [0; 56];
        file.read_exact(&mut entry)?;
        if u32::from_le_bytes(entry[..4].try_into().unwrap()) == 3 {
            let offset = u64::from_le_bytes(entry[8..16].try_into().unwrap());
            let length = u64::from_le_bytes(entry[32..40].try_into().unwrap());
            if length > 4096 {
                return Err(Error::Invalid("Invalid ELF interpreter length".into()));
            }
            file.seek(SeekFrom::Start(offset))?;
            let mut name = vec![0; length as usize];
            file.read_exact(&mut name)?;
            return Ok(PathBuf::from(
                String::from_utf8_lossy(&name).trim_end_matches('\0'),
            ));
        }
    }
    Err(Error::Invalid(
        "Cannot determine the host ELF interpreter".into(),
    ))
}
#[cfg(not(target_os = "linux"))]
fn linux_interpreter() -> Result<PathBuf> {
    unreachable!()
}

#[cfg(test)]
mod tests {
    use super::normalise_library_search_path;

    #[test]
    fn library_search_accepts_canonical_windows_directories() {
        for (path, expected) in [
            (
                r"\\?\C:\wheel with spaces\runtime",
                r"C:\wheel with spaces\runtime",
            ),
            (r"\\?\UNC\server\share\runtime", r"\\server\share\runtime"),
            (r"C:\wheel\runtime", r"C:\wheel\runtime"),
            (r"\\server\share\runtime", r"\\server\share\runtime"),
            (
                r"\\?\Volume{identifier}\runtime",
                r"\\?\Volume{identifier}\runtime",
            ),
        ] {
            assert_eq!(normalise_library_search_path(path), expected);
        }
    }
}
