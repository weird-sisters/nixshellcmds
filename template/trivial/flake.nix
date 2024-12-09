{
  description = "Minimum template";

  inputs = {
    nixshellcmds.url = "github:weird-sisters/nixshellcmds";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nixshellcmds.flakeModules.flakeCmds
        inputs.nixshellcmds.flakeModules.shellInit
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    };
}