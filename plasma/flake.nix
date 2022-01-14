{
  description = "KDE Plasma";

  outputs = { self, ... }: {
    home = { config, lib, pkgs, ... }: {

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
