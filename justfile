develop:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/hugrenv-env.sh
    if [[ "$(uname -s)" == "Darwin" && -f selene-sim/python/selene_sim/_dist/bin/llvm-symbolizer && ! -L selene-sim/python/selene_sim/_dist/bin/llvm-symbolizer ]]; then
        uv sync --reinstall-package selene-sim
    else
        uv sync
    fi

clean-artifacts:
    rm -rf **/_dist
    find . -wholename "*/c/build" -type d -exec rm -rf {} \;

build-wheels:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/hugrenv-env.sh
    if [[ "${SELENE_HUGRENV_FROM_HOMEBREW:-}" == 1 ]]; then
        echo "Local Homebrew LLVM tools depend on Homebrew libraries; use a portable HUGRENV_PATH for distributable wheels." >&2
    fi
    uv build --all-packages

test-py *TEST_ARGS: develop
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/hugrenv-env.sh
    uv run pytest {{TEST_ARGS}}

test-rs *TEST_ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/hugrenv-env.sh
    uv run cargo test {{TEST_ARGS}}

nitpicks:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/hugrenv-env.sh
    cargo fmt --all -- --check
    cargo clippy --all --all-features -- -D warnings
    RUSTDOCFLAGS="-Dwarnings" cargo doc --no-deps --all-features
    uv sync
    (
        cd selene-core
        uv run mypy .
    )
    uv run mypy selene-sim selene-ext/*/*/python/*_plugin
    uv run ruff format --check --config=pyproject.toml
    uv run ruff check --config=pyproject.toml

BIND_BUILD := "target/selene-bindings-build"
generate-selene-core-headers:
    cbindgen \
      --config selene-core/cbindgen/core_types.toml \
      --crate selene-core \
      --output selene-core/c/include/selene/core_types.h

    cbindgen \
      --config selene-core/cbindgen/error_model.toml \
      --crate selene-core \
      --output selene-core/c/include/selene/error_model.h

    cbindgen \
      --config selene-core/cbindgen/simulator.toml \
      --crate selene-core \
      --output selene-core/c/include/selene/simulator.h

    cbindgen \
      --config selene-core/cbindgen/runtime.toml \
      --crate selene-core \
      --output selene-core/c/include/selene/runtime.h

generate-headers:
    just generate-selene-core-headers
    just generate-selene-sim-headers

generate-selene-sim-headers:
    cbindgen \
      --config selene-sim/cbindgen.toml \
      --crate selene-sim \
      --output selene-sim/c/include/selene/selene.h

generate-selene-sim-bindings: generate-selene-sim-headers
    mkdir -p {{BIND_BUILD}}

    cmake \
      -B{{BIND_BUILD}} \
      -DCMAKE_INSTALL_PREFIX=selene-sim/python/selene_sim/_dist \
      selene-sim/c

    cmake \
      --build {{BIND_BUILD}} \
      --target install

    rm -rf {{BIND_BUILD}}

generate-bindings: generate-selene-core-headers generate-selene-sim-bindings

build-ci:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/hugrenv-env.sh
    mkdir -p /tmp/ci-cache
    export CACHE_CARGO=true
    uv build --package selene-core --out-dir wheelhouse
    uvx cibuildwheel .
