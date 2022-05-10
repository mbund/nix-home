{
  description = "Custom desktop environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nur, ... }@inputs: {
    home = { config, lib, pkgs, ... }:
      let system = pkgs.system; in
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nur.overlay ];
        };

        localfile = path: config.lib.file.mkOutOfStoreSymlink ("${config.home.homeDirectory}/nix-home/" + path);
      in
      {
        home.packages = with pkgs; [
          kitty
          imv
          flameshot
          mpv
          zathura
          helvum

          # gtk apps
          fragments
          blanket
          gaphor
          khronos
          kooha
          metadata-cleaner
          mousai
        ];

        xdg.configFile."kitty/kitty.conf".source = localfile "mbund-gnome/kitty.conf";

        programs.chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;
          commandLineArgs = [
            "--enable-features=UseOzonePlatform"
            "--ozone-platform=wayland"
          ];
        };

        dconf.settings = {
          "org/gnome/calculator" = {
            button-mode = "programming";
            show-thousands = true;
            base = 10;
            word-size = 64;
          };
          "org/gnome/desktop/background" = {
            picture-uri = "file:///home/mbund/data/pictures/wallpaper.png";
          };
          "org/gnome/desktop/wm/preferences" = {
            resize-with-right-button = true;
            button-layout = ":close";
          };
          "org/gnome/shell" = {
            disable-user-extensions = false; # enable gnome extensions
          };
          "org/gnome/desktop/input-sources" = {
            xkb-options = [ "caps:escape_shifted_capslock" ];
          };
        };

        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          size = 16;

          package = pkgs.nur.repos.ambroisie.vimix-cursors;
          name = "Vimix-white-cursors";
        };

        gtk = {
          enable = true;
          theme.name = "Adwaita";
          iconTheme.name = "Adwaita";
        };

        fonts.fontconfig.enable = true;

        home.sessionVariables = {
          XCURSOR_THEME = config.xsession.pointerCursor.name;
          XCURSOR_SIZE = config.xsession.pointerCursor.size;

          MOZ_ENABLE_WAYLAND = 1;
          GDK_BACKEND = "wayland,x11";
          QT_QPA_PLATFORM = "wayland;xcb";
          NIXOS_OZONE_WL = 1;
          _JAVA_AWT_WM_NONREPARENTING = 1;
        };

      };
  };
}
