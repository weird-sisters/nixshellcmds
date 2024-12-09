{ devshell, ... }:
{ inputs, ... }: let

  ds = if (inputs ? devshell) then inputs.devshell else devshell;

in {
  imports = [
    ds.flakeModule
  ];
}
