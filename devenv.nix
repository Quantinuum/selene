{ pkgs, lib, inputs, config, ... }:
let
  hugrenv = pkgs.callPackage ./hugrenv.nix { packages = ["llvm"]; };
in {
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
      "LIBCLANG_PATH" = "${hugrenv}/lib";
      "HUGRENV_PATH" = "${hugrenv}";
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
        package = pkgs.uv;
        entry = "${pkgs.uv}/bin/uv run --locked ruff check --fix";
        args = ["--config=pyproject.toml"];
        pass_filenames = true;
      };
      ruff-format = {
        enable = true;
        package = pkgs.uv;
        entry = "${pkgs.uv}/bin/uv run --locked ruff format";
        args = ["--config=pyproject.toml"];
        pass_filenames = true;
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
      schema-immutability = {
        enable = true;
        name = "Schema immutability";
        description = "Prevent changes to JSON Schemas already present on origin/0.3-series.";
        package = pkgs.python3;
        entry = "${pkgs.python3}/bin/python3 selene-protocol/scripts/check_schema_immutability.py";
        args = ["--base=origin/0.3-series" "--staged"];
        files = "^(selene-protocol/schemas/.*\\.schema\\.json|selene-protocol/scripts/check_schema_immutability\\.py|devenv\\.nix)$";
        pass_filenames = false;
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
