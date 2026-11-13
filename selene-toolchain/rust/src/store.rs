use crate::{Artifact, ArtifactKind, Error, Executor, Plan, Result, digest};
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
    /// Build with the default single-worker executor.
    pub fn build(&self, plan: &Plan) -> Result<BuildResult> {
        Executor::new(self.clone()).build(plan)
    }
    pub(crate) fn with_build_lock<T>(&self, build: impl FnOnce() -> Result<T>) -> Result<T> {
        let lock = self.lock("store")?;
        FileExt::lock_shared(&lock)?;
        build()
    }
    pub(crate) fn temporary_directory(&self) -> Result<tempfile::TempDir> {
        let root = self.root.join("temporary");
        fs::create_dir_all(&root)?;
        Ok(tempfile::tempdir_in(root)?)
    }
    pub(crate) fn capture(&self, artifact: &Artifact) -> Result<PathBuf> {
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
    pub(crate) fn build_cached(
        &self,
        description: serde_json::Value,
        kind: ArtifactKind,
        cacheable: bool,
        execute: impl FnOnce() -> Result<(Artifact, String)>,
    ) -> Result<BuildResult> {
        let key = digest(&serde_json::to_vec(&description)?);
        let lock = self.lock(&key)?;
        lock.lock_exclusive()?;
        let directory = self.root.join("builds");
        fs::create_dir_all(&directory)?;
        let record_path = directory.join(format!("{key}.json"));
        if cacheable && record_path.is_file() {
            let record: Record = serde_json::from_slice(&fs::read(&record_path)?)?;
            if record.schema != 1 || record.description != description || record.kind != kind {
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
        let (artifact, diagnostics) = execute()?;
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
