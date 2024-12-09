{
  description = "Exposes devshell commonly used menu commands";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    systems.url = "github:nix-systems/default";
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.flakeCmds = importApply ./flake-modules/flakeCmds.nix {
          inherit flake-parts-lib;
          inherit (inputs) nixpkgs-lib;
          inherit flakeModules;
        };
        flakeModules.shellInit = importApply ./flake-modules/shellInit.nix {
          inherit flake-parts-lib;
          inherit (inputs) nixpkgs-lib;
          inherit flakeModules;
        };
        flakeModules.devshellCompat = importApply ./flake-modules/devshellCompat.nix {
          inherit (inputs) devshell;
        };
        templates = {
          trivial = {
            path = ./template/trivial;
            description = ''
              A minimal flake using nixshellcmds.
            '';
          };
        };
      in
      {
        imports = [
          flakeModules.flakeCmds
          flakeModules.shellInit
        ];

        systems = import inputs.systems;

        perSystem = {...}: {
          shellInit.envrc.content = ''
          if ! has nix_direnv_version || ! nix_direnv_version 2.2.1; then
            source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/2.2.1/direnvrc" "sha256-zelF0vLbEl5uaqrfIzbgNzJWGmLzCmYAkInj/LNxvKs="
          fi

          watch_file flake.nix
          watch_file flake.lock
          watch_file flake-modules/*.nix

          if ! use flake . --impure --show-trace
          then
            echo "devenv could not be built. The devenv environment was not loaded. Make the necessary changes to devenv.nix and hit enter to try again." >&2
          fi
          '';

          flakeCommands.push.enable = true;
        };
        
        flake = {
          inherit templates flakeModules;
        };
      }
    );
}
