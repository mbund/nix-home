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
        extraConfig = {
          XDG_MISC_DIR = "$HOME/data/misc";
        };
      };

      home.packages = with pkgs; [
        nix-index
        nix-tree
        nix-prefetch-scripts
        nixops
        zip
        unzip
      ];

      systemd.user.services.setup-home = {
        Unit = {
          Description = "Setup home directory";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
        
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = let
            homeDir = "/home/mbund";

            sync = source: destination: "[ -d ${source} ] && ${pkgs.rsync}/bin/rsync -av --ignore-existing --remove-source-files ${source} ${destination} && ${pkgs.coreutils}/bin/rmdir -v ${source}";

            script = pkgs.writeShellScript "setup-home.sh" ''
              mkdir -p ${homeDir}/data/{desktop,documents,downloads,music,pictures,public,templates,videos,misc,isos}

              ${sync "${homeDir}/Desktop/" "${homeDir}/data/desktop"}
              ${sync "${homeDir}/Documents/" "${homeDir}/data/documents"}
              ${sync "${homeDir}/Downloads/" "${homeDir}/data/downloads"}
              ${sync "${homeDir}/Music/" "${homeDir}/data/music"}
              ${sync "${homeDir}/Pictures/" "${homeDir}/data/pictures"}
              ${sync "${homeDir}/Public/" "${homeDir}/data/public"}
              ${sync "${homeDir}/Templates/" "${homeDir}/data/templates"}
              ${sync "${homeDir}/Videos/" "${homeDir}/data/videos"}
            ''; in "${script}";
        };
      };

      systemd.user.startServices = "sd-switch";

      programs.home-manager.enable = true;
    };
  };
}
