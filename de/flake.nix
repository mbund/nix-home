{
  description = "Custom desktop environment";

  inputs = {
  };

  outputs = { self, ... }@inputs: {
    home = { config, lib, pkgs, ... }: {
      
      home.packages = with pkgs; [
        hikari
        xwayland
        
        alacritty
        
        wl-clipboard
        
        imv
        cinnamon.nemo
      ];
      
      # configure hikari window manager
      home.xdg.configFile."hikari/hikari.conf".source = ./hikari.conf;      
      
      programs.mako = {
        enable = true;
      };
      
      services.flameshot = {
        enable = true;
      };
      
      prgrams.mpv = {
        enable = true;
      };
      
      programs.zathura = {
        enable = true;
      };

      gtk = {
        enable = true;
        theme = {
          name = "Breeze";
          package = pkgs.gnome-breeze;
        };

        iconTheme = {
          name = "Breeze";
          package = pkgs.gnome.adwaita-icon-theme;
        };
      };

    };
  };
}
