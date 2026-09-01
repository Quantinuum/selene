{ pkgs, lib, inputs, config, ... }:
{
  config = {
    packages = with pkgs; [
      cmake
      just
      zlib
      libxml2
      ncurses
      rust-cbindgen
      graphviz
      graph-easy
      libffi
      cargo-expand
      nodejs_22
      pnpm
      typescript
    ];

    enterShell = ''
      eval "$(just --completions bash)"
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    '';

    env = {
      LIBCLANG_PATH = "${pkgs.libclang.lib}";
    };


    languages.python = {
      enable = true;
      uv.enable = true;
      uv.sync.enable = true;
      venv.enable = true;
    };

    languages.rust = {
      enable = true;
      rustflags = "-L${config.env.DEVENV_PROFILE}/lib";
      components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
      toolchainFile = ./rust-toolchain.toml;
    };

    git-hooks.hooks = {
      ruff = {
        enable = true;
        args = ["--config=pyproject.toml"];
        pass_filenames = false;
      };
      ruff-format = {
        enable = true;
        args = ["--config=pyproject.toml"];
        pass_filenames = false;
      };
      clippy = {
        enable = true;
        settings = {
          denyWarnings = true;
        };
      };
      cargo-check = {
        enable = true;
      };
      rustfmt = {
        enable = true;
      };
      mypy = {
        enable = true;
        # Pre-commit invokes this hook concurrently for file batches. Disable
        # Mypy's shared incremental cache to avoid cache-corruption assertions.
        args = ["--config=pyproject.toml" "--no-incremental"];
        extraPackages = with pkgs.python3Packages; [
          types-pyyaml
        ];
        excludes = [
          "selene-sim/python/tests"
          "selene-ext/simulators/quest/python/gate_definitions.py"
          "selene-ext/simulators/stim/python/gate_definitions.py"
        ];
      };
      api-models-python-test = {
        enable = true;
        name = "API models Python tests";
        description = "Run the Python API model test suite.";
        package = pkgs.uv;
        entry = "uv run --locked --package selene-api-models --group test pytest selene-protocol/python/tests";
        files = "^(selene-protocol/.*|Cargo\\.(toml|lock)|pyproject\\.toml|uv\\.lock|pnpm(-workspace)?\\.yaml|devenv\\.nix)$";
        pass_filenames = false;
      };
      api-models-rust-test = {
        enable = true;
        name = "API models Rust tests";
        description = "Run the Rust API model test suite.";
        package = pkgs.cargo;
        entry = "cargo test --package selene-api-models";
        files = "^(selene-protocol/.*|Cargo\\.(toml|lock)|pyproject\\.toml|uv\\.lock|pnpm(-workspace)?\\.yaml|devenv\\.nix)$";
        pass_filenames = false;
      };
      api-models-typescript-test = {
        enable = true;
        name = "API models TypeScript tests";
        description = "Install locked dependencies and run the TypeScript API model test suite.";
        package = pkgs.pnpm;
        entry = "${pkgs.writeShellScript "api-models-typescript-test" ''
          ${pkgs.pnpm}/bin/pnpm install --frozen-lockfile
          ${pkgs.pnpm}/bin/pnpm --filter @quantinuum/selene-api-models test
        ''}";
        files = "^(selene-protocol/.*|Cargo\\.(toml|lock)|pyproject\\.toml|uv\\.lock|pnpm(-workspace)?\\.yaml|devenv\\.nix)$";
        pass_filenames = false;
      };
    };
  };
}
