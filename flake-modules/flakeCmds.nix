{ lib, mkPerSystemOption, ... }:
let
  inherit (lib)
    mkOption
    types
    optional
    mapAttrsToList
    mkAliasDefinitions
    ;
  inherit (lib.attrsets)
    mapAttrs;
in
{ ... }:
{
  options.perSystem = mkPerSystemOption (
    { config, options, ... }:
    let
      cfg = config.flakeCommands;
      
      mkCmd = args@{
        self,
        name,
        command,
        isFlakeCommand ? true,
        descriptiveName ? if isFlakeCommand then "flake ${self.name}" else "${self.name}",
        purpose ? null,
        helpMessage ? if purpose == null then "The ${descriptiveName} command!" else "The ${descriptiveName} command ${purpose}",
        enable ? true
      }:
      let
        description = {
          enable = "Enable command";
          name = "Name of the command";
          command = "Command to run";
          help = "Help message";
        };
      in
      {
        enable = mkOption {
          description = ''
            ${description.enable}
          '';
          type = types.bool;
          default = enable;
        };
        name = mkOption {
          description = ''
            ${description.name}
          '';
          type = types.str;
          default = name;
        };
        command = mkOption {
          description = ''
            ${description.command}
          '';
          type = types.str;
          default = ''
            pushd $PRJ_ROOT
            ${command}
          '';
        };
        help = mkOption {
          description = ''
            ${description.help}
          '';
          type = types.str;
          default = "${helpMessage}";
        };
      };
    in
    {
      options.flakeCommands.defaults = mkOption {
        type = types.attrsOf (types.separatedString " --option ");
        default = {
          nix-flake-update = "accept-flake-config true";
        };
        apply = dfs: (mapAttrs (_: value: if value == "" then value else "--option " + value ) dfs);
      };
      options.flakeCommands.check = mkCmd {
        self = cfg.check;
        name = "check";
        purpose = "performs a simple check.";
        command = ''nix flake check "$@" --impure'';
      };

      options.flakeCommands.checkAll = mkCmd {
        self = cfg.checkAll;
        name = "check-all";
        purpose = "runs a full check.";
        command = ''nix flake check "$@" --all-systems --impure --no-pure-eval'';
      };

      options.flakeCommands.show = mkCmd {
        self = cfg.show;
        name = "show";
        purpose = "shows the outputs.";
        command = ''nix flake show "$@" --impure'';
      };

      options.flakeCommands.showAll = mkCmd {
        self = cfg.showAll;
        name = "show-all";
        purpose = "shows all the outputs.";
        command = ''nix flake show "$@" --all-systems --legacy --impure --no-pure-eval'';
      };

      options.flakeCommands.update = mkCmd {
        self = cfg.update;
        name = "update";
        purpose = "update inputs.";
        command = ''nix flake update ${cfg.defaults.nix-flake-update} "$@"'';
      };

      options.flakeCommands.push = mkCmd {
        self = cfg.push;
        enable = false;
        name = "push";
        purpose = "push to cachix.";
        isFlakeCommand = false;
        command = ''nix flake archive "$@" --json | jq -r '.path,(.inputs|to_entries[].value.path)' | cachix push tarc'';
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

      options.commands = mkOption {
        type = types.attrs;
        default = {};
      };

      config.flakeCommands.commands = (mapAttrsToList (name: command: {
        name = name;
        command = command;
        help = "Run ${command}.";
      }) config.commands )
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
