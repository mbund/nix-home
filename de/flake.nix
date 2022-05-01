{
  description = "Custom desktop environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nur, ... }@inputs: {
    home = { config, lib, pkgs, ... }:
      let
        nurpkgs = import nixpkgs {
          system = pkgs.system;
          overlays = [ nur.overlay ];
        };

        launch-hikari = pkgs.writeScriptBin "launch-hikari" ''
          #!/usr/bin/env bash

          # neofetch needs theses to detect hikari
          export XDG_CURRENT_DESKTOP=hikari
          export XDG_SESSION_DESKTOP=hikari

          # enable wob
          export WOBSOCK="$XDG_RUNTIME_DIR"/wob.sock

          # fix wayland on nvidia
          export WLR_NO_HARDWARE_CURSORS=1

          dbus-launch hikari
        '';
      in
      {
        home.packages = with pkgs; [
          hikari
          xwayland
          launch-hikari

          wl-clipboard
          wob
          brightnessctl
          pamixer

          imv
          cinnamon.nemo
        ];

        # configure hikari window manager
        xdg.configFile."hikari/hikari.conf".source = ./hikari.conf;
        xdg.configFile."hikari/autostart" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash

            rm -f "$WOBSOCK" && mkfifo "$WOBSOCK"
            (tail -f "$WOBSOCK" | wob) &
          '';
        };

        programs.kitty = {
          enable = true;
          extraConfig = ''
            dynamic_background_opacity yes
            background_opacity 0.8

            ${builtins.readFile ./onedark-kitty.conf}
          '';
        };

        programs.rofi = {
          enable = true;
          package = pkgs.rofi-wayland;
          plugins = with pkgs; [ rofi-calc rofi-emoji ];
          terminal = "${pkgs.kitty}/bin/kitty";
          theme = ./arc-dark.rasi;
        };

        programs.mako = {
          enable = true;
        };

        services.flameshot = {
          enable = true;
          package = (pkgs.symlinkJoin {
            name = "flameshot";
            paths = [ pkgs.flameshot ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/flameshot \
                --set XDG_CURRENT_DESKTOP sway
            '';
          });
        };

        programs.mpv = {
          enable = true;
        };

        programs.zathura = {
          enable = true;
        };

        xsession.enable = true;
        xsession.pointerCursor = {
          size = 16;

          package = nurpkgs.nur.repos.ambroisie.vimix-cursors;
          name = "Vimix-white-cursors";
          # name = "Vimix-cursors";

          # package = pkgs.capitaine-cursors;
          # name = "capitaine-cursors";

          # package = nurpkgs.nur.repos.ambroisie.volantes-cursors;
          # name = "volantes_light_cursors";
          # name = "volantes_cursors";

          # package = nurpkgs.nur.repos.dan4ik605743.lyra-cursors;
          # name = "LyraF-cursors";
        };

        home.sessionVariables = {
          # wlroots based wayland compositors read these to set their cursor
          XCURSOR_THEME = config.xsession.pointerCursor.name;
          XCURSOR_SIZE = config.xsession.pointerCursor.size;

          # enable wayland for firefox
          MOZ_ENABLE_WAYLAND = 1;
        };

        gtk = {
          enable = true;
          theme = {
            package = pkgs.libsForQt5.breeze-gtk;
            name = "Breeze";
          };

          iconTheme = {
            package = pkgs.libsForQt5.breeze-icons;
            name = "Breeze";
          };
        };

      };
  };
}
