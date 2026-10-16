# Publishing bindings

Release Please manages the Python, Rust, and TypeScript bindings as one
`selene-api-models` component. A release PR updates every distribution to the
same version. Merging it creates this tag:

- `selene-api-models-v<version>`

The API model packages workflow tests and packages all three bindings before it
publishes all three distributions. Releases are coordinated but not atomic.

The binding packages share one version, which remains independent from a trace
document's `schema_version`.

Selene's wheel tests install the Python API models directly from
`selene-trace/`, alongside `selene-core/`. This lets us test model changes
before publishing a new API models release. `just build-ci` uses the same
installation steps locally through cibuildwheel. Run it inside devenv.
