# `nixshellcmds`

## Existing `flake-parts` project

Add `github:weird-sisters/nixshellcmds"` to the `inputs` section and import the modules:

```nix
{
  inputs = {
    # ...
    nixshellcmds.url = "github:weird-sisters/nixshellcmds";
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        # ...
        inputs.nixshellcmds.flakeModules.flakeCmds
        inputs.nixshellcmds.flakeModules.shellInit
      ];

      systems = [
        # ...
      ];

      perSystem = {...}: {
        # ...
      };
    };
}
```

## Templates

You can start by creating a trivial project from the template:

```shell
nix flake new --template github:weird-sisters/nixshellcmds#trivial ./ws-trivial
```

After that, enter the newly created directory and force the creation of `.envrc` and other initial files:

```shell
cd ws-trivial
nix develop ".#default"
```

After the last command you'll be in a simple development shell. Leave it and allow the project directory with `direnv`:

```shell
exit
direnv allow .
```

After *allowing* the directory with `direnv` from now on, everytime you enter this directory all required setup will be carried out automatically for you.
