use crate::{Artifact, ArtifactKind, Input, Plan, Store, Toolchain};
use pyo3::{exceptions::PyRuntimeError, prelude::*};
use std::path::PathBuf;

fn error(error: crate::Error) -> PyErr {
    PyRuntimeError::new_err(error.to_string())
}
fn kind(name: &str) -> PyResult<ArtifactKind> {
    match name {
        "bitcode" => Ok(ArtifactKind::Bitcode),
        "object" => Ok(ArtifactKind::Object),
        "static_library" => Ok(ArtifactKind::StaticLibrary),
        "shared_library" => Ok(ArtifactKind::SharedLibrary),
        "executable" => Ok(ArtifactKind::Executable),
        _ => Err(PyRuntimeError::new_err("Unknown artifact kind")),
    }
}
#[pyclass(name = "Artifact", frozen, skip_from_py_object)]
#[derive(Clone)]
struct PyArtifact {
    inner: Artifact,
}
#[pymethods]
impl PyArtifact {
    #[staticmethod]
    fn from_bytes(kind_name: &str, bytes: Vec<u8>) -> PyResult<Self> {
        Ok(Self {
            inner: Artifact::from_bytes(kind(kind_name)?, bytes),
        })
    }
    #[staticmethod]
    fn from_path(kind_name: &str, path: PathBuf) -> PyResult<Self> {
        Ok(Self {
            inner: Artifact::from_path(kind(kind_name)?, path).map_err(error)?,
        })
    }
    #[getter]
    fn digest(&self) -> String {
        self.inner.digest().into()
    }
    #[getter]
    fn kind(&self) -> String {
        serde_json::to_value(self.inner.kind())
            .unwrap()
            .as_str()
            .unwrap()
            .into()
    }
    fn copy_to(&self, path: PathBuf) -> PyResult<()> {
        self.inner.copy_to(path).map_err(error)
    }
    fn bytes(&self) -> Vec<u8> {
        self.inner.bytes().to_vec()
    }
}
#[pyclass(name = "Plan", frozen, skip_from_py_object)]
#[derive(Clone)]
struct PyPlan {
    inner: Plan,
}
#[pymethods]
impl PyPlan {
    fn describe(&self) -> String {
        serde_json::to_string_pretty(&self.inner.describe()).unwrap()
    }
}
#[pyclass(name = "Toolchain", frozen)]
struct PyToolchain {
    inner: Toolchain,
}
#[pymethods]
impl PyToolchain {
    #[new]
    fn new(root: PathBuf) -> PyResult<Self> {
        Ok(Self {
            inner: Toolchain::from_directory(root).map_err(error)?,
        })
    }
    fn version(&self) -> PyResult<String> {
        self.inner.version().map_err(error)
    }
    fn inspect(&self, py: Python<'_>, artifact: &PyArtifact) -> PyResult<String> {
        let artifact = artifact.inner.clone();
        py.detach(|| self.inner.inspect(&artifact).map(|v| v.to_string()))
            .map_err(error)
    }
    fn compile_plan(
        &self,
        py: Python<'_>,
        source: &PyArtifact,
        optimisation: u8,
        retarget: bool,
    ) -> PyResult<PyPlan> {
        let source = source.inner.clone();
        py.detach(|| {
            self.inner
                .compile(source)
                .optimisation(optimisation)
                .retarget(retarget)
                .plan()
        })
        .map(|inner| PyPlan { inner })
        .map_err(error)
    }
    fn link_plan(
        &self,
        py: Python<'_>,
        inputs: Vec<Bound<'_, PyAny>>,
        system: Vec<String>,
        search: Vec<PathBuf>,
        flags: Vec<String>,
        shared: bool,
    ) -> PyResult<PyPlan> {
        let mut builder = if shared {
            self.inner.link_shared_library()
        } else {
            self.inner.link_executable()
        };
        for input in inputs {
            let input = if let Ok(artifact) = input.extract::<PyRef<PyArtifact>>() {
                Input::Artifact(artifact.inner.clone())
            } else {
                Input::Plan(input.extract::<PyRef<PyPlan>>()?.inner.clone())
            };
            builder = builder.object(input);
        }
        for name in system {
            builder = builder.system_library(name);
        }
        for path in search {
            builder = builder.search_directory(path);
        }
        for flag in flags {
            builder = builder.link_flag(flag);
        }
        py.detach(|| builder.plan())
            .map(|inner| PyPlan { inner })
            .map_err(error)
    }
    // Used by reader tests to generate foreign objects. Public build plans
    // deliberately support only the distribution's native target for now.
    fn compile_bytes(&self, py: Python<'_>, data: Vec<u8>, target: String) -> PyResult<Vec<u8>> {
        py.detach(|| {
            self.inner.backend.run(
                "compile",
                &data,
                &serde_json::json!({"target": target, "optimisation": 0}),
            )
        })
        .map_err(error)
    }
}
#[pyclass(name = "Store", frozen)]
struct PyStore {
    inner: Store,
}
#[pyclass(name = "BuildResult", frozen)]
struct PyResultRecord {
    result: crate::BuildResult,
}
#[pymethods]
impl PyStore {
    #[new]
    #[pyo3(signature = (root=None))]
    fn new(root: Option<PathBuf>) -> PyResult<Self> {
        Ok(Self {
            inner: match root {
                Some(path) => Store::local(path),
                None => Store::default_location(),
            }
            .map_err(error)?,
        })
    }
    fn build(&self, py: Python<'_>, plan: &PyPlan) -> PyResult<PyResultRecord> {
        let plan = plan.inner.clone();
        py.detach(|| self.inner.build(&plan))
            .map(|result| PyResultRecord { result })
            .map_err(error)
    }
    #[pyo3(signature = (dry_run=false))]
    fn clean(&self, py: Python<'_>, dry_run: bool) -> PyResult<u64> {
        py.detach(|| self.inner.clean(dry_run)).map_err(error)
    }
    #[getter]
    fn root(&self) -> PathBuf {
        self.inner.root().into()
    }
}
#[pymethods]
impl PyResultRecord {
    #[getter]
    fn artifact(&self) -> PyArtifact {
        PyArtifact {
            inner: self.result.artifact.clone(),
        }
    }
    #[getter]
    fn path(&self) -> PathBuf {
        self.result.path.clone()
    }
    #[getter]
    fn cache_hit(&self) -> bool {
        self.result.cache_hit
    }
    #[getter]
    fn diagnostics(&self) -> String {
        self.result.diagnostics.clone()
    }
    #[getter]
    fn key(&self) -> String {
        self.result.key.clone()
    }
}
#[pyfunction]
fn _shutdown(py: Python<'_>) {
    py.detach(crate::backend::shutdown);
}

#[pymodule]
fn _native(module: &Bound<'_, PyModule>) -> PyResult<()> {
    module.add_function(wrap_pyfunction!(_shutdown, module)?)?;
    module.add_class::<PyArtifact>()?;
    module.add_class::<PyPlan>()?;
    module.add_class::<PyToolchain>()?;
    module.add_class::<PyStore>()?;
    module.add_class::<PyResultRecord>()?;
    Ok(())
}
