# Source this from just recipes that invoke a Python package build.
if [[ -z "${HUGRENV_PATH:-}" ]] && [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null; then
    llvm_prefix="$(brew --prefix llvm 2>/dev/null || true)"
    if [[ -x "$llvm_prefix/bin/llvm-symbolizer" && -x "$llvm_prefix/bin/dsymutil" ]]; then
        export HUGRENV_PATH="$llvm_prefix"
        export SELENE_HUGRENV_FROM_HOMEBREW=1
    fi
    unset llvm_prefix
fi
