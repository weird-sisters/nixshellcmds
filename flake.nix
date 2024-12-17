{
  description = "Exposes devshell commonly used menu commands";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixpkgs-unstable?dir=lib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
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
          inherit (flake-parts-lib) mkPerSystemOption;
          inherit (inputs.nixpkgs-lib) lib;
        };
        flakeModules.shellInit = importApply ./flake-modules/shellInit.nix {
          inherit (flake-parts-lib) mkPerSystemOption;
          inherit (inputs.nixpkgs-lib) lib;
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
          inputs.devshell.flakeModule
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
