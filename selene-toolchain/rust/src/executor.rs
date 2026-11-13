use crate::{
    Artifact, ArtifactKind, BuildResult, Error, Input, LinkArg, LinkError, Operation, Plan, Result,
    Store, path_string,
};
use rayon::prelude::*;
use std::{path::Path, sync::Arc};

struct CapturedLinkInput {
    path: String,
    artifact: Artifact,
}

/// Execute build plans against a store, with a bounded pool of workers.
#[derive(Clone)]
pub struct Executor {
    store: Store,
    pool: Option<Arc<rayon::ThreadPool>>,
}

impl Executor {
    pub fn new(store: Store) -> Self {
        Self { store, pool: None }
    }
    /// Set the maximum number of workers for this executor's build plans.
    /// Scheduling doesn't change the plans or their cache keys.
    pub fn with_jobs(mut self, jobs: usize) -> Result<Self> {
        if jobs == 0 {
            return Err(Error::Invalid("jobs must be greater than zero".into()));
        }
        self.pool = if jobs == 1 {
            None
        } else {
            Some(Arc::new(
                rayon::ThreadPoolBuilder::new()
                    .num_threads(jobs)
                    .thread_name(|index| format!("selene-build-{index}"))
                    .build()
                    .map_err(|error| {
                        Error::Invalid(format!("Cannot start build workers: {error}"))
                    })?,
            ))
        };
        Ok(self)
    }
    pub fn jobs(&self) -> usize {
        self.pool
            .as_ref()
            .map_or(1, |pool| pool.current_num_threads())
    }
    pub fn store(&self) -> &Store {
        &self.store
    }
    pub fn build(&self, plan: &Plan) -> Result<BuildResult> {
        self.store.with_build_lock(|| match &self.pool {
            Some(pool) => pool.install(|| self.build_inner(plan)),
            None => self.build_inner(plan),
        })
    }
    fn build_inner(&self, plan: &Plan) -> Result<BuildResult> {
        let mut inputs = vec![];
        if let Operation::Link {
            inputs: dependencies,
            ..
        } = &plan.0.operation
        {
            let build = |input: &Input| match input {
                Input::Artifact(a) => Ok(a.clone()),
                Input::Plan(p) => self.build_inner(p).map(|result| result.artifact),
            };
            inputs = if self.pool.is_some() && dependencies.len() > 1 {
                // Rayon keeps the input order when collecting an indexed
                // iterator. Link order therefore stays the same even if the
                // compilations finish in a different order.
                dependencies.par_iter().map(build).collect::<Result<_>>()?
            } else {
                dependencies.iter().map(build).collect::<Result<_>>()?
            };
        }
        let mut description = plan.describe();
        if let Operation::Link { .. } = &plan.0.operation {
            // Link results contain paths to stored shared libraries. A local
            // store is deliberately not yet a relocatable binary cache.
            description["store"] = serde_json::json!(self.store.root());
            // Depend on actual object bytes rather than how they were built.
            description["inputs"] =
                serde_json::json!(inputs.iter().map(Artifact::identity).collect::<Vec<_>>());
        }
        let cacheable = !matches!(
            &plan.0.operation,
            Operation::Link {
                cacheable: false,
                ..
            }
        );
        self.store
            .build_cached(description, plan.kind(), cacheable, || {
                self.execute(plan, &inputs)
            })
    }
    fn execute(&self, plan: &Plan, inputs: &[Artifact]) -> Result<(Artifact, String)> {
        let temporary = self.store.temporary_directory()?;
        let mut diagnostics = String::new();
        let artifact = match &plan.0.operation {
            Operation::Compile {
                source,
                optimisation,
                retarget,
            } => {
                self.store.capture(source)?;
                let bytes = plan.0.backend.run(
                    "compile",
                    source.bytes(),
                    &serde_json::json!({"target": plan.0.target, "optimisation": optimisation, "retarget": retarget, "name": source.name()}),
                )?;
                let name = Path::new(source.name()).with_extension("o");
                Artifact::from_bytes(ArtifactKind::Object, bytes).with_name(path_string(&name)?)?
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
                let mut references = vec![];
                for argument in arguments {
                    match argument {
                        LinkArg::Text(s) => args.push(s.clone()),
                        LinkArg::Output => args.push(path_string(&output)?),
                        LinkArg::File(a) => self.link_input(a, &mut args, &mut references)?,
                        LinkArg::Dependency(a) => {
                            self.store.capture(a)?;
                        }
                        LinkArg::Input(i) => {
                            self.link_input(&inputs[*i], &mut args, &mut references)?
                        }
                    }
                }
                let linked = plan.0.backend.run("link", &[], &serde_json::json!(args));
                let bytes = match linked {
                    Ok(bytes) => bytes,
                    Err(Error::Operation { diagnostics, .. }) => {
                        return Err(link_error(diagnostics, &references, &output).into());
                    }
                    Err(error) => return Err(error),
                };
                diagnostics = String::from_utf8_lossy(&bytes).into_owned();
                Artifact::from_path(*kind, &output)?
            }
        };
        Ok((artifact, diagnostics))
    }
    fn link_input(
        &self,
        artifact: &Artifact,
        args: &mut Vec<String>,
        references: &mut Vec<CapturedLinkInput>,
    ) -> Result<()> {
        let path = self.store.capture(artifact)?;
        references.push(CapturedLinkInput {
            path: path_string(&path)?,
            artifact: artifact.clone(),
        });
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
}

fn link_error(
    raw_diagnostics: String,
    references: &[CapturedLinkInput],
    output: &Path,
) -> LinkError {
    let mut inputs = vec![];
    let mut replacements = vec![];
    for reference in references {
        let artifact = &reference.artifact;
        let ambiguous = references.iter().any(|other| {
            other.artifact.name == artifact.name && other.artifact.digest != artifact.digest
        });
        let name = if ambiguous {
            format!("{} [{}]", artifact.name, &artifact.digest[..12])
        } else {
            artifact.name.clone()
        };
        if !inputs.contains(&name) {
            inputs.push(name.clone());
        }
        replacements.push((reference.path.clone(), name));
    }
    replacements.push((
        output.to_string_lossy().into_owned(),
        output.file_name().unwrap().to_string_lossy().into_owned(),
    ));
    // Replace only paths we passed to LLD. Archive member names, source
    // locations and the rest of the diagnostic should stay as LLD reported them.
    let mut paths = vec![];
    for (path, name) in replacements {
        let short = if let Some(unc) = path.strip_prefix(r"\\?\UNC\") {
            format!(r"\\{unc}")
        } else {
            path.strip_prefix(r"\\?\").unwrap_or(&path).to_owned()
        };
        for variant in [&path, &short] {
            paths.push((variant.clone(), name.clone()));
            paths.push((variant.replace('\\', "/"), name.clone()));
            paths.push((variant.replace('/', "\\"), name.clone()));
        }
    }
    paths.sort_by_key(|(path, _)| std::cmp::Reverse(path.len()));
    let mut diagnostics = raw_diagnostics.clone();
    for (path, name) in paths {
        diagnostics = diagnostics.replace(&path, &name);
    }
    LinkError::from_lld(raw_diagnostics, &diagnostics, inputs)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn windows_archive_paths_keep_the_member_name() -> Result<()> {
        let reference = CapturedLinkInput {
            path: r"\\?\C:\cache\artifacts\digest\plugin.a".into(),
            artifact: Artifact::from_bytes(ArtifactKind::StaticLibrary, b"archive".to_vec())
                .with_name("plugin.a")?,
        };
        let raw = "undefined symbol: missing\n>>> referenced by C:/cache/artifacts/digest/plugin.a(member.o)\n";
        let error = link_error(raw.into(), &[reference], Path::new("program.exe"));
        assert_eq!(error.raw_diagnostics, raw);
        assert_eq!(
            error.diagnostics,
            "Undefined symbol `missing`\n  Referenced in plugin.a(member.o)"
        );
        assert_eq!(error.inputs, vec!["plugin.a"]);
        Ok(())
    }

    #[test]
    fn unc_paths_are_hidden_without_rewriting_source_locations() -> Result<()> {
        let reference = CapturedLinkInput {
            path: r"\\?\UNC\server\share\artifacts\digest\caller.o".into(),
            artifact: Artifact::from_bytes(ArtifactKind::Object, b"object".to_vec())
                .with_name("caller.o")?,
        };
        let raw = "ld.lld: error: undefined symbol: missing\n>>> referenced by /source/original.c:12\n>>> //server/share/artifacts/digest/caller.o:(main)\n";
        let error = link_error(raw.into(), &[reference], Path::new("program.exe"));
        assert_eq!(error.raw_diagnostics, raw);
        assert_eq!(
            error.diagnostics,
            "Undefined symbol `missing`\n  Referenced by main in caller.o\n    at /source/original.c:12"
        );
        Ok(())
    }
}
