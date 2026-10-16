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
    ];

    enterShell = ''
      eval "$(just --completions bash)"
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    '';

    env = {
      "LIBCLANG_PATH" = "${hugrenv}/lib";
      "HUGRENV_PATH" = "${hugrenv}";
    };


    languages.javascript = {
      enable = true;
      package = pkgs.nodejs_22;
      pnpm.enable = true;
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
        entry = "${pkgs.python3}/bin/python3 selene-formats/scripts/check_schema_immutability.py";
        args = ["--base=origin/0.3-series" "--staged"];
        files = "^(selene-formats/schemas/.*\\.schema\\.json|selene-formats/scripts/check_schema_immutability\\.py|devenv\\.nix)$";
        pass_filenames = false;
      };
      schema-validation = {
        enable = true;
        name = "Schema ID validation";
        description = "Check that JSON Schema IDs match their publishing URLs.";
        package = pkgs.python3;
        entry = "${pkgs.python3}/bin/python3 selene-formats/scripts/validate_schemas.py";
        always_run = true;
        pass_filenames = false;
      };
      formats-package-versions = {
        enable = true;
        name = "Formats package versions";
        description = "Check that all formats packages share the same version.";
        package = pkgs.python3;
        entry = "${pkgs.python3}/bin/python3 selene-formats/scripts/check_package_versions.py";
        always_run = true;
        pass_filenames = false;
      };
      formats-python-test = {
        enable = true;
        name = "Formats Python tests";
        description = "Run the Python formats test suite.";
        package = pkgs.uv;
        entry = "uv run --locked --package selene-formats --group test pytest selene-formats/python/tests";
        files = "^(selene-formats/.*|Cargo\\.(toml|lock)|pyproject\\.toml|uv\\.lock|pnpm(-workspace)?\\.yaml|devenv\\.nix)$";
        pass_filenames = false;
      };
      formats-rust-test = {
        enable = true;
        name = "Formats Rust tests";
        description = "Run the Rust formats test suite.";
        package = pkgs.cargo;
        entry = "cargo test --package selene-formats";
        files = "^(selene-formats/.*|Cargo\\.(toml|lock)|pyproject\\.toml|uv\\.lock|pnpm(-workspace)?\\.yaml|devenv\\.nix)$";
        pass_filenames = false;
      };
      formats-typescript-test = {
        enable = true;
        name = "Formats TypeScript tests";
        description = "Install locked dependencies and run the TypeScript formats test suite.";
        package = config.languages.javascript.pnpm.package;
        entry = "${pkgs.writeShellScript "formats-typescript-test" ''
          ${config.languages.javascript.pnpm.package}/bin/pnpm install --frozen-lockfile
          ${config.languages.javascript.pnpm.package}/bin/pnpm --filter @quantinuum/selene-formats test
        ''}";
        files = "^(selene-formats/.*|Cargo\\.(toml|lock)|pyproject\\.toml|uv\\.lock|pnpm(-workspace)?\\.yaml|devenv\\.nix)$";
        pass_filenames = false;
      };
    };
  };
}
