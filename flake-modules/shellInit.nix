{ flake-parts-lib, nixpkgs-lib, flakeModules, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (nixpkgs-lib.lib)
    mkOption
    types
    optionalAttrs
    mkAliasDefinitions
    ;
in
{ ... }: {
  imports = [
    flakeModules.devshellCompat
  ];
  options.perSystem = mkPerSystemOption (
    { config, options, ... }:
    let
      cfg = config.shellInit;
      mkFileCheck = { self, file, content, enable ? true }: {
        enable = mkOption {
          description = ''
            Enable ${file} file check and generation when entering the shell.

            Check if the file ${file} exists in the project root and create it otherwise.
          '';
          type = types.bool;
          default = enable;
        };
        content = mkOption {
          description = ''
            ${file} file content.

            It's suited for flake projects!
          '';
          type = types.str;
          default = content;
        };
        command = mkOption {
          description = ''
            The command to check and create the ${file}

            Check and create ${file}.
          '';
          type = types.str;
          default = ''
            echo Checking: ${file}
            pushd $PRJ_ROOT
            if [[ -e ${file} ]]; then
              echo File ${file} already exists...
            else
              echo Checking directory: $(dirname ${file})
              mkdir -p $(dirname ${file})
              cat <<EOF > ${file}
            ${self.content}
            EOF
            fi
          '';
        };
      };
    in
    {
      options.shellInit.envrc = mkFileCheck {
        self = cfg.envrc;
        file = ".envrc";
        content = ''
          if ! has nix_direnv_version || ! nix_direnv_version 2.2.1; then
            source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/2.2.1/direnvrc" "sha256-zelF0vLbEl5uaqrfIzbgNzJWGmLzCmYAkInj/LNxvKs="
          fi

          watch_file flake.nix
          watch_file flake.lock
          watch_file flake-module.nix
          watch_file modules/*.nix

          if ! use flake . --impure --show-trace
          then
            echo "devenv could not be built. The devenv environment was not loaded. Make the necessary changes to devenv.nix and hit enter to try again." >&2
          fi
        '';
      };

      options.shellInit.vscode = mkFileCheck {
        self = cfg.vscode;
        file = ".vscode/settings.json";
        content = ''
          {
            "nix.serverPath": "nixd",
            "nix.enableLanguageServer": true
          }
        '';
      };

      options.shellInit.startup = mkOption {
        internal = true;
        type = types.attrs;
        default = { };
      };

      config.shellInit.startup = {
        }
        // optionalAttrs cfg.envrc.enable {
          dot-envrc = {
            text = cfg.envrc.command;
          };
          dot-vscode = {
            text = cfg.vscode.command;
          };
        }
        // {
        };

      options.shellInit.devshellAttr = mkOption {
        description = ''
          To which devshell to add commands?

          This defaults to default.
        '';
        type = types.str;
        default = "default";
      };

      config.devshells.${cfg.devshellAttr} = {
        devshell.startup = mkAliasDefinitions options.shellInit.startup;
      };
    }
  );
}
