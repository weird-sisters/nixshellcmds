{ flake-parts-lib, nixpkgs-lib, flakeModules, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (nixpkgs-lib.lib)
    mkOption
    types
    optional
    mkAliasDefinitions
    ;
in
{ ... }:
{
  imports = [
    flakeModules.devshellCompat
  ];

  options.perSystem = mkPerSystemOption (
    { config, options, ... }:
    let
      cfg = config.flakeCommands;
    in
    {
      options.flakeCommands.check = {
        enable = mkOption {
          description = ''
            Enable flake check command.

            This is a simplified version of check-all command.
          '';
          type = types.bool;
          default = false;
        };
        name = mkOption {
          description = ''
            Check command name.

            check?
          '';
          type = types.str;
          default = "check";
        };
        command = mkOption {
          description = ''
            The actual command to run.

            nix flake check something
          '';
          type = types.str;
          default = ''
            pushd $PRJ_ROOT
            nix flake check "$@" --impure
          '';
        };
        help = mkOption {
          description = ''
            Help message.

            help!
          '';
          type = types.str;
          default = "Check the things";
        };
      };

      options.flakeCommands.checkAll = {
        enable = mkOption {
          description = ''
            Enable flake check-all command.

            Check everything.
          '';
          type = types.bool;
          default = true;
        };
        name = mkOption {
          description = ''
            Check all command name.

            check?
          '';
          type = types.str;
          default = "check-all";
        };
        command = mkOption {
          description = ''
            The actual command to run.

            nix flake check --all --kill --destroy or something
          '';
          type = types.str;
          default = ''
            pushd $PRJ_ROOT
            nix flake check "$@" --all-systems --impure --no-pure-eval
          '';
        };
        help = mkOption {
          description = ''
            Help message.

            help!
          '';
          type = types.str;
          default = "Check all the things";
        };
      };

      options.flakeCommands.show = {
        enable = mkOption {
          description = ''
            Enable flake show command.

            This is a simplified version of show-all command.
          '';
          type = types.bool;
          default = false;
        };
        name = mkOption {
          description = ''
            Show command name.

            show?
          '';
          type = types.str;
          default = "show";
        };
        command = mkOption {
          description = ''
            The actual command to run.

            nix flake show something
          '';
          type = types.str;
          default = ''
            pushd $PRJ_ROOT
            nix flake show "$@" --impure
          '';
        };
        help = mkOption {
          description = ''
            Help message.

            help!
          '';
          type = types.str;
          default = "Show something";
        };
      };

      options.flakeCommands.showAll = {
        enable = mkOption {
          description = ''
            Enable flake show-all command.

            Show everything.
          '';
          type = types.bool;
          default = true;
        };
        name = mkOption {
          description = ''
            Show all command name.

            show-all?
          '';
          type = types.str;
          default = "show-all";
        };
        command = mkOption {
          description = ''
            The actual command to run.

            nix flake show --all --todo --alles
          '';
          type = types.str;
          default = ''
            pushd $PRJ_ROOT
            nix flake show "$@" --all-systems --legacy --impure --no-pure-eval
          '';
        };
        help = mkOption {
          description = ''
            Help message.

            help!
          '';
          type = types.str;
          default = "Show everything!";
        };
      };

      options.flakeCommands.update = {
        enable = mkOption {
          description = ''
            Enable update command.

            Update it.
          '';
          type = types.bool;
          default = true;
        };
        name = mkOption {
          description = ''
            Update command name.

            update?
          '';
          type = types.str;
          default = "update";
        };
        command = mkOption {
          description = ''
            The actual command to run.

            nix flake update ...
          '';
          type = types.str;
          default = ''
            pushd $PRJ_ROOT
            nix flake update "$@"
          '';
        };
        help = mkOption {
          description = ''
            Help message.

            help!
          '';
          type = types.str;
          default = "Updata las flakes, caro senor!";
        };
      };

      options.flakeCommands.push = {
        enable = mkOption {
          description = ''
            Enable cachix push.

            Push it.
          '';
          type = types.bool;
          default = false;
        };
        name = mkOption {
          description = ''
            Push cache command name.

            push?
          '';
          type = types.str;
          default = "push";
        };
        command = mkOption {
          description = ''
            The actual command to run.

            nix flake archive etc.
          '';
          type = types.str;
          default = ''
            pushd $PRJ_ROOT
            nix flake archive "$@" --json | jq -r '.path,(.inputs|to_entries[].value.path)' | cachix push tarc
          '';
        };
        help = mkOption {
          description = ''
            Help message.

            help!
          '';
          type = types.str;
          default = "Push to cachix!";
        };
      };

      options.flakeCommands.commands = mkOption {
        internal = true;
        type = types.listOf types.attrs;
        default = [ ];
      };

      options.flakeCommands.devshellAttr = mkOption {
        description = ''
          To which devshell to add commands?

          This defaults to default.
        '';
        type = types.str;
        default = "default";
      };

      config.flakeCommands.commands = [ ]
        ++ optional cfg.check.enable {
          name = cfg.check.name;
          command = cfg.check.command;
          help = cfg.check.help;
        }
        ++ optional cfg.checkAll.enable {
          name = cfg.checkAll.name;
          command = cfg.checkAll.command;
          help = cfg.checkAll.help;
        }
        ++ optional cfg.show.enable {
          name = cfg.show.name;
          command = cfg.show.command;
          help = cfg.show.help;
        }
        ++ optional cfg.showAll.enable {
          name = cfg.showAll.name;
          command = cfg.showAll.command;
          help = cfg.showAll.help;
        }
        ++ optional cfg.update.enable {
          name = cfg.update.name;
          command = cfg.update.command;
          help = cfg.update.help;
        }
        ++ optional cfg.push.enable {
          name = cfg.push.name;
          command = cfg.push.command;
          help = cfg.push.help;
        };

      config.devshells.${cfg.devshellAttr} = {
        commands = mkAliasDefinitions options.flakeCommands.commands;
      };
    }

  );
}
