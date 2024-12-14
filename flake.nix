{
  description = "Exposes devshell commonly used menu commands";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin?dir=lib";
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

          shellInit.watchFiles = "watch_file flake-modules/*.nix";

          flakeCommands.push.enable = true;
        };
        
        flake = {
          inherit templates flakeModules;
        };
      }
    );
}
