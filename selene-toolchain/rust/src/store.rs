use crate::{
    Artifact, ArtifactKind, Error, Input, LinkArg, Operation, Plan, Result, digest, path_string,
};
use fs2::FileExt;
use serde::{Deserialize, Serialize};
use std::{
    fs::{self, File, OpenOptions},
    io::Write,
    path::{Path, PathBuf},
};

#[derive(Clone)]
pub struct Store {
    root: PathBuf,
}
pub struct BuildResult {
    pub artifact: Artifact,
    pub path: PathBuf,
    pub cache_hit: bool,
    pub diagnostics: String,
    pub key: String,
}
#[derive(Serialize, Deserialize)]
struct Record {
    schema: u32,
    digest: String,
    name: String,
    kind: ArtifactKind,
    diagnostics: String,
    description: serde_json::Value,
}

impl Store {
    pub fn local(root: impl AsRef<Path>) -> Result<Self> {
        fs::create_dir_all(root.as_ref())?;
        Ok(Self {
            root: root.as_ref().canonicalize()?,
        })
    }
    pub fn default_location() -> Result<Self> {
        if let Some(root) = std::env::var_os("SELENE_TOOLCHAIN_CACHE") {
            return Self::local(root);
        }
        Self::local(cache_directory()?.join("selene-toolchain/v1"))
    }
    pub fn root(&self) -> &Path {
        &self.root
    }
    fn lock(&self, name: &str) -> Result<File> {
        let directory = self.root.join("locks");
        fs::create_dir_all(&directory)?;
        Ok(OpenOptions::new()
            .create(true)
            .truncate(false)
            .read(true)
            .write(true)
            .open(directory.join(name))?)
    }
    pub fn build(&self, plan: &Plan) -> Result<BuildResult> {
        let lock = self.lock("store")?;
        FileExt::lock_shared(&lock)?;
        self.build_inner(plan)
    }
    fn capture(&self, artifact: &Artifact) -> Result<PathBuf> {
        let directory = self.root.join("artifacts").join(&artifact.digest);
        fs::create_dir_all(&directory)?;
        let path = directory.join(&artifact.name);
        if !path.exists() {
            let mut temporary = tempfile::NamedTempFile::new_in(&directory)?;
            temporary.write_all(artifact.bytes())?;
            if artifact.kind == ArtifactKind::Executable {
                executable(temporary.path())?;
            }
            match temporary.persist_noclobber(&path) {
                Ok(_) => {}
                Err(error) if error.error.kind() == std::io::ErrorKind::AlreadyExists => {}
                Err(error) => return Err(error.error.into()),
            }
        }
        // Store corruption must never become a successful cache hit or change
        // a build's inputs without changing its key.
        if digest(&fs::read(&path)?) != artifact.digest {
            return Err(Error::Invalid(format!(
                "Corrupt store artifact: {}",
                path.display()
            )));
        }
        Ok(path)
    }
    fn build_inner(&self, plan: &Plan) -> Result<BuildResult> {
        let mut inputs = vec![];
        if let Operation::Link {
            inputs: dependencies,
            ..
        } = &plan.0.operation
        {
            for input in dependencies {
                inputs.push(match input {
                    Input::Artifact(a) => a.clone(),
                    Input::Plan(p) => self.build_inner(p)?.artifact,
                });
            }
        }
        let mut description = plan.describe();
        if let Operation::Link { .. } = &plan.0.operation {
            // Link results contain paths to stored shared libraries. A local
            // store is deliberately not yet a relocatable binary cache.
            description["store"] = serde_json::json!(self.root);
            // Depend on actual object bytes rather than how they were built.
            description["inputs"] =
                serde_json::json!(inputs.iter().map(Artifact::identity).collect::<Vec<_>>());
        }
        let key = digest(&serde_json::to_vec(&description)?);
        let lock = self.lock(&key)?;
        lock.lock_exclusive()?;
        let directory = self.root.join("builds");
        fs::create_dir_all(&directory)?;
        let record_path = directory.join(format!("{key}.json"));
        let cacheable = !matches!(
            &plan.0.operation,
            Operation::Link {
                cacheable: false,
                ..
            }
        );
        if cacheable && record_path.is_file() {
            let record: Record = serde_json::from_slice(&fs::read(&record_path)?)?;
            if record.schema != 1 || record.description != description || record.kind != plan.kind()
            {
                return Err(Error::Invalid(format!(
                    "Invalid build record: {}",
                    record_path.display()
                )));
            }
            let path = self
                .root
                .join("artifacts")
                .join(&record.digest)
                .join(&record.name);
            if path.is_file() {
                let artifact = Artifact::from_path(record.kind, &path)?;
                if artifact.digest != record.digest {
                    return Err(Error::Invalid(format!(
                        "Corrupt cached output: {}",
                        path.display()
                    )));
                }
                return Ok(BuildResult {
                    artifact,
                    path,
                    cache_hit: true,
                    diagnostics: record.diagnostics,
                    key,
                });
            }
        }
        let temporary_root = self.root.join("temporary");
        fs::create_dir_all(&temporary_root)?;
        let temporary = tempfile::tempdir_in(&temporary_root)?;
        let mut diagnostics = String::new();
        let artifact = match &plan.0.operation {
            Operation::Compile {
                source,
                optimisation,
                retarget,
            } => {
                self.capture(source)?;
                let bytes = plan.0.backend.run(
                    "compile",
                    source.bytes(),
                    &serde_json::json!({"target": plan.0.target, "optimisation": optimisation, "retarget": retarget}),
                )?;
                Artifact::from_bytes(ArtifactKind::Object, bytes)
            }
            Operation::Link {
                arguments, kind, ..
            } => {
                let output = temporary.path().join(if *kind == ArtifactKind::Executable {
                    "program.exe"
                } else if cfg!(windows) {
                    "library.dll"
                } else if cfg!(target_os = "macos") {
                    "library.dylib"
                } else {
                    "library.so"
                });
                let mut args = vec![];
                for argument in arguments {
                    match argument {
                        LinkArg::Text(s) => args.push(s.clone()),
                        LinkArg::Output => args.push(path_string(&output)?),
                        LinkArg::File(a) => self.link_input(a, &mut args)?,
                        LinkArg::Dependency(a) => {
                            self.capture(a)?;
                        }
                        LinkArg::Input(i) => self.link_input(&inputs[*i], &mut args)?,
                    }
                }
                diagnostics = String::from_utf8_lossy(&plan.0.backend.run(
                    "link",
                    &[],
                    &serde_json::json!(args),
                )?)
                .into_owned();
                Artifact::from_path(*kind, &output)?
            }
        };
        let path = self.capture(&artifact)?;
        let record = Record {
            schema: 1,
            digest: artifact.digest.clone(),
            name: artifact.name.clone(),
            kind: artifact.kind,
            diagnostics: diagnostics.clone(),
            description,
        };
        if cacheable {
            let mut temporary = tempfile::NamedTempFile::new_in(&directory)?;
            temporary.write_all(&serde_json::to_vec_pretty(&record)?)?;
            // The per-key lock makes replacement safe on Windows too.
            if record_path.exists() {
                fs::remove_file(&record_path)?;
            }
            temporary.persist(&record_path).map_err(|e| e.error)?;
        }
        Ok(BuildResult {
            artifact,
            path,
            cache_hit: false,
            diagnostics,
            key,
        })
    }
    fn link_input(&self, artifact: &Artifact, args: &mut Vec<String>) -> Result<()> {
        let path = self.capture(artifact)?;
        if artifact.kind == ArtifactKind::SharedLibrary && !cfg!(windows) {
            // Use a library search rather than an absolute input path so a
            // library without a SONAME doesn't record a temporary filename.
            let parent = path.parent().unwrap();
            args.push(format!("-L{}", path_string(parent)?));
            if cfg!(target_os = "macos") {
                args.push(path_string(&path)?);
            } else {
                args.push(format!("-l:{}", artifact.name));
            }
            args.push("-rpath".into());
            args.push(path_string(parent)?);
        } else {
            args.push(path_string(&path)?);
        }
        Ok(())
    }
    /// Evict cached results while preserving captured inputs and shared
    /// libraries that exported executables may still need. Full GC requires
    /// explicit roots; don't guess which external executables still exist.
    pub fn clean(&self, dry_run: bool) -> Result<u64> {
        let lock = self.lock("store")?;
        lock.lock_exclusive()?;
        let mut size = 0;
        for name in ["builds", "temporary"] {
            let path = self.root.join(name);
            if path.exists() {
                size += directory_size(&path)?;
                if !dry_run {
                    fs::remove_dir_all(path)?;
                }
            }
        }
        Ok(size)
    }
}
pub(crate) fn cache_directory() -> Result<PathBuf> {
    let root = if cfg!(windows) {
        std::env::var_os("LOCALAPPDATA").map(PathBuf::from)
    } else if cfg!(target_os = "macos") {
        std::env::var_os("HOME").map(|home| PathBuf::from(home).join("Library/Caches"))
    } else {
        std::env::var_os("XDG_CACHE_HOME")
            .map(PathBuf::from)
            .or_else(|| std::env::var_os("HOME").map(|home| PathBuf::from(home).join(".cache")))
    };
    root.ok_or_else(|| {
        Error::Invalid("No cache directory available; supply an explicit location".into())
    })
}
fn directory_size(path: &Path) -> Result<u64> {
    let mut total = 0;
    for entry in fs::read_dir(path)? {
        let entry = entry?;
        total += if entry.file_type()?.is_dir() {
            directory_size(&entry.path())?
        } else {
            entry.metadata()?.len()
        };
    }
    Ok(total)
}
pub(crate) fn executable(path: &Path) -> Result<()> {
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(path, fs::Permissions::from_mode(0o755))?;
    }
    let _ = path;
    Ok(())
}
