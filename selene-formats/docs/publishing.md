# Publishing bindings

Release Please manages the Python, Rust, and TypeScript bindings as one
`selene-formats` component. A release PR updates every distribution to the
same version. Merging it creates this tag:

- `selene-formats-v<version>`

The formats packages workflow tests and packages all three bindings before it
publishes all three distributions. Releases are coordinated but not atomic.

The binding packages share one version, which remains independent from a trace
document's `schema_version`.

Selene's wheel tests install the Python formats package directly from
`selene-formats/`, alongside `selene-core/`. This lets us test model changes
before publishing a new formats release. `just build-ci` uses the same
installation steps locally through cibuildwheel. Run it inside devenv.
