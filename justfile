develop:
    uv sync

# Download the Hugrenv LLVM tools pinned in hugrenv.lock into .hugrenv/.
hugrenv:
    #!/usr/bin/env bash
    set -euo pipefail
    version="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' hugrenv.lock)"
    case "$(uname -s)-$(uname -m)" in
        Linux-x86_64) target=manylinux_2_28_x86_64 ;;
        Linux-aarch64) target=manylinux_2_28_aarch64 ;;
        Darwin-x86_64) target=macosx_11_0_x86_64 ;;
        Darwin-arm64) target=macosx_11_0_aarch64 ;;
        MINGW*-x86_64|MSYS*-x86_64|CYGWIN*-x86_64) target=win_amd64 ;;
        *) echo "Unsupported platform: $(uname -s) $(uname -m)" >&2; exit 1 ;;
    esac
    if [[ "$(cat .hugrenv/.version 2>/dev/null)" == "$version-$target" ]]; then
        echo "Hugrenv $version ($target) is already installed in .hugrenv"
        exit 0
    fi
    url="https://github.com/Quantinuum/hugrverse-env/releases/download/v$version/hugrenv-llvm-$target.tar.gz"
    echo "Downloading $url"
    rm -rf .hugrenv
    mkdir -p .hugrenv
    curl -fsSL "$url" | tar -xzf - -C .hugrenv --strip-components=1
    echo "$version-$target" > .hugrenv/.version

clean-artifacts:
    rm -rf **/_dist
    find . -wholename "*/c/build" -type d -exec rm -rf {} \;

build-wheels:
    uv build --all-packages

test-py *TEST_ARGS: develop
    uv run pytest {{TEST_ARGS}}

test-rs *TEST_ARGS:
    uv run cargo test {{TEST_ARGS}}

nitpicks:
    #!/usr/bin/env bash
    set -euo pipefail
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
    mkdir -p /tmp/ci-cache
    export CACHE_CARGO=true
    uv build --package selene-core --out-dir wheelhouse
    uvx cibuildwheel .
