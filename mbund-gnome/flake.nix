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
          "org/gnome/desktop/peripherals/mouse" = {
            accel-profile = "flat";
          };
          "org/gnome/shell" = {
            disable-user-extensions = false; # enable gnome extensions
          };
          "org/gnome/desktop/sound" = {
            allow-volume-above-100-percent = true;
          };
          "org/gnome/desktop/input-sources" = {
            xkb-options = [ "caps:escape_shifted_capslock" ];
          };
          "org/gnome/mutter/keybindings" = {
            switch-monitor = [ "XF86Display" ]; # remove the default '<Super>P'
            toggle-tiled-left = [ "<Super><Alt>X" ];
            toggle-tiled-right = [ "<Super><Alt>C" ];
          };
          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Super>C" ];

            raise = [ "<Super>R" ];
            lower = [ "<Super>G" ];
            always-on-top = [ "<Super>T" ];

            toggle-fullscreen = [ "<Super>F" ];
            maximize-horizontally = [ "<Super><Alt>V" ];
            maximize-vertically = [ "<Super><Alt>Z" ];
            move-to-side-w = [ "<Super><Shift>H" ];
            move-to-side-s = [ "<Super><Shift>J" ];
            move-to-side-n = [ "<Super><Shift>K" ];
            move-to-side-e = [ "<Super><Shift>L" ];
            move-to-monitor-left = [ "<Super>H" ];
            move-to-monitor-down = [ "<Super>J" ];
            move-to-monitor-up = [ "<Super>K" ];
            move-to-monitor-right = [ "<Super>L" ];
            move-to-center = [ "<Super><Shift>N" ];
            move-to-corner-nw = [ "<Super><Alt>J" ];
            move-to-corner-ne = [ "<Super><Alt>K" ];
            move-to-corner-sw = [ "<Super><Alt>H" ];
            move-to-corner-se = [ "<Super><Alt>L" ];

            switch-to-workspace-1 = [ "<Super>1" ];
            switch-to-workspace-2 = [ "<Super>2" ];
            switch-to-workspace-3 = [ "<Super>3" ];
            switch-to-workspace-4 = [ "<Super>4" ];
            switch-to-workspace-5 = [ "<Super>5" ];
            switch-to-workspace-6 = [ "<Super>6" ];
            switch-to-workspace-7 = [ "<Super>7" ];
            switch-to-workspace-8 = [ "<Super>8" ];
            switch-to-workspace-9 = [ "<Super>9" ];
            switch-to-workspace-10 = [ "<Super>0" ];

            move-to-workspace-1 = [ "<Super><Shift>1" ];
            move-to-workspace-2 = [ "<Super><Shift>2" ];
            move-to-workspace-3 = [ "<Super><Shift>3" ];
            move-to-workspace-4 = [ "<Super><Shift>4" ];
            move-to-workspace-5 = [ "<Super><Shift>5" ];
            move-to-workspace-6 = [ "<Super><Shift>6" ];
            move-to-workspace-7 = [ "<Super><Shift>7" ];
            move-to-workspace-8 = [ "<Super><Shift>8" ];
            move-to-workspace-9 = [ "<Super><Shift>9" ];
            move-to-workspace-10 = [ "<Super><Shift>0" ];

            toggle-maximized = [ "<Super><Shift>M" ];
            minimize = [ "<Super>M" ];
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            screensaver = [ "<Super>P" ];
          };
          "org/gnome/shell/keybindings" = {
            switch-to-application-1 = [ ];
            switch-to-application-2 = [ ];
            switch-to-application-3 = [ ];
            switch-to-application-4 = [ ];
            switch-to-application-5 = [ ];
            switch-to-application-6 = [ ];
            switch-to-application-7 = [ ];
            switch-to-application-8 = [ ];
            switch-to-application-9 = [ ];
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
