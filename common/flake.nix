{
  description = "Common";

  outputs = { self, ... }: {
    home = { config, lib, pkgs, ... }: {
      xdg.userDirs = {
        enable = true;
        desktop = "$HOME/xdg/desktop";
        documents = "$HOME/xdg/documents";
        download = "$HOME/xdg/downloads";
        music = "$HOME/xdg/music";
        pictures = "$HOME/xdg/pictures";
        publicShare = "$HOME/xdg/public";
        templates = "$HOME/xdg/templates";
        videos = "$HOME/xdg/videos";
        extraConfig = {
          XDG_MISC_DIR = "$HOME/xdg/misc";
        };
      };

      home.packages = with pkgs; [
        nix-index
      ];

      home.username = "mbund";
      home.homeDirectory = "/home/mbund";
      home.stateVersion = "21.11";
      programs.home-manager.enable = true;
    };
  };
}
