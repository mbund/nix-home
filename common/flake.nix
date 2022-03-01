{
  description = "Common";

  outputs = { self, ... }: {
    home = { config, lib, pkgs, ... }: {
      xdg.userDirs = {
        enable = true;
        desktop = "$HOME/data/desktop";
        documents = "$HOME/data/documents";
        download = "$HOME/data/downloads";
        music = "$HOME/data/music";
        pictures = "$HOME/data/pictures";
        publicShare = "$HOME/data/public";
        templates = "$HOME/data/templates";
        videos = "$HOME/data/videos";
      };

      home.packages = with pkgs; [
        nix-tree
        nix-index
        nix-prefetch-scripts
        nixops
        comma
      ];

      programs.zsh.initExtra = ''
        command_not_found_handle () {
          # taken from http://www.linuxjournal.com/content/bash-command-not-found
          # - do not run when inside Midnight Commander or within a Pipe
          if [ -n "''${MC_SID-}" ] || ! [ -t 1 ]; then
              >&2 echo "$1: command not found"
              return 127
          fi

          cmd=$1
          attrs=$(${pkgs.nix-index}/bin/nix-locate --minimal --no-group --type x --type s --top-level --whole-name --at-root "/bin/$cmd")
          len=$(echo -n "$attrs" | grep -c "^")

          case $len in
            0)
              >&2 echo "$cmd: command not found in nixpkgs (run nix-index to update the index)"
              ;;
            *)
              >&2 echo "$cmd was found in the following derivations:\n"
              while read attr; do
                >&2 echo "nixpkgs#$attr"
              done <<< "$attrs"
              ;;
          esac

          return 127 # command not found should always exit with 127
        }

        command_not_found_handler () {
          command_not_found_handle $@
          return $?
        }
      '';

      systemd.user.services.home-manager-setup-home = {
        Unit = {
          Description = "Setup home directory";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart =
            let
              homeDir = config.home.homeDirectory;

              sync = source: destination: "if [ -d ${source} ]; then ${pkgs.rsync}/bin/rsync -av --ignore-existing --remove-source-files ${source} ${destination} && ${pkgs.coreutils}/bin/rmdir -v ${source}; fi";

              script = pkgs.writeShellScript "setup-home.sh" ''
                mkdir -p ${homeDir}/data/{desktop,documents,downloads,music,pictures,public,templates,videos}

                ${sync "${homeDir}/Desktop/" "${homeDir}/data/desktop"}
                ${sync "${homeDir}/Documents/" "${homeDir}/data/documents"}
                ${sync "${homeDir}/Downloads/" "${homeDir}/data/downloads"}
                ${sync "${homeDir}/Music/" "${homeDir}/data/music"}
                ${sync "${homeDir}/Pictures/" "${homeDir}/data/pictures"}
                ${sync "${homeDir}/Public/" "${homeDir}/data/public"}
                ${sync "${homeDir}/Templates/" "${homeDir}/data/templates"}
                ${sync "${homeDir}/Videos/" "${homeDir}/data/videos"}
              '';
            in
            "${script}";
        };
      };

      systemd.user.startServices = "suggest";

      programs.home-manager.enable = true;
    };
  };
}



