{
  description = "mbund's home-manager configuration for all systems";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-pinned";
    };

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-pinned.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, home-manager, nur, ... }@mbund-inputs:
    let
      lib = mbund-inputs.nixpkgs-stable.lib;

      genStablePkgs = system: import mbund-inputs.nixpkgs-stable { inherit system; };

      genPinnedPkgs = system: import mbund-inputs.nixpkgs-pinned {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          # steam is required for lutris
          "steam"
          "steam-original"
          "steam-runtime"

          "code"
          "vscode"

          "zoom"

          "spotify-unwrapped"
        ];
      };

      genMasterPkgs = system: import mbund-inputs.nixpkgs-master {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          "code"
          "vscode"
        ];
      };

      genNurpkgs = system: import mbund-inputs.nixpkgs-master {
        inherit system;
        overlays = [ nur.overlay ];
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];
      };

    in
    {

      genHomeConfigurations = parentInputs: {
        "mbund@mbund-desktop" = home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";
          stateVersion = "21.11";
          homeDirectory = "/home/mbund";
          username = "mbund";
          configuration =
            let
              inputs = parentInputs // mbund-inputs;
              stable-pkgs = genStablePkgs system;
              pinned-pkgs = genPinnedPkgs system;
              master-pkgs = genMasterPkgs system;
              nurpkgs = genNurpkgs system;

              oneshotPkg = input: import input { inherit system; config = { allowUnfree = true; allowBroken = true; }; };

            in
            { config, ... }: ({
              imports = with inputs; [
                common.home
                cli.home
                mbund-gnome.home
                signing.home
              ];

              programs.obs-studio = {
                enable = true;
                # plugins = with pinned-pkgs.obs-studio-plugins; [
                #   obs-nvfbc
                #   obs-multi-rtmp
                # ];
              };

              dconf.settings = {
                "org/gnome/settings-daemon/plugins/power" = {
                  sleep-inactive-ac-type = "nothing";
                };
                "org/gnome/shell" = {
                  # gnome dock, from left to right
                  favorite-apps = [
                    "com.rafaelmardojai.Blanket.desktop"
                    "ferdi.desktop"
                    "org.gnome.Nautilus.desktop"
                    "net.lutris.Lutris.desktop"
                    "librewolf.desktop"
                    "kitty.desktop"
                  ];
                };
              };

              home.packages = with pinned-pkgs; [
                # audio/video
                calf
                ardour
                lmms
                qpwgraph
                playerctl
                vlc
                audacity
                pitivi
                libsForQt5.kdenlive

                # social/entertainment
                (pkgs.symlinkJoin {
                  name = "ferdi";
                  paths = [ pkgs.ferdi ];
                  buildInputs = [ pkgs.makeWrapper ];
                  postBuild = ''
                    wrapProgram $out/bin/ferdi \
                      --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
                  '';
                })
                (lutris.overrideAttrs (_: { buildInputs = [ xdelta ]; }))

                # art
                krita
                inkscape
                gimp
                blender

                # school/productivity
                onlyoffice-bin
                gnucash
                graphviz
                xdot
                dot2tex
                liberation_ttf

                # programming
                master-pkgs.vscode-fhs
                godot
                ghidra

                # system
                gparted
                virt-manager

                # misc
                librewolf
                aspell
                aspellDicts.en
                qbittorrent
                tor
              ];

            });
        };

        "mbund@marshmellow-roaster" = home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";
          stateVersion = "21.11";
          homeDirectory = "/home/mbund";
          username = "mbund";
          configuration =
            let
              inputs = parentInputs // mbund-inputs;
              stable-pkgs = genStablePkgs system;
              pinned-pkgs = genPinnedPkgs system;
              master-pkgs = genMasterPkgs system;
            in
            { config, ... }: ({
              imports = with inputs; [
                common.home
                cli.home
                # plasma.home
                mbund-gnome.home
                signing.home
              ];

              home.packages = with pinned-pkgs; [
                vscodium
                virt-manager
                godot
                gparted
              ];

            });
        };

        "mbund@zephyr" = home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";
          stateVersion = "21.11";
          homeDirectory = "/home/mbund";
          username = "mbund";
          configuration =
            let
              inputs = parentInputs // mbund-inputs;
              stable-pkgs = genStablePkgs system;
              pinned-pkgs = genPinnedPkgs system;
              master-pkgs = genMasterPkgs system;
            in
            { config, ... }: ({
              imports = with inputs; [
                common.home
                cli.home
                signing.home
              ];

              home.packages = with pinned-pkgs; [
                vlc
                tor
              ];

              home.sessionVariables = {
                "EDITOR" = "nvim";
                "VISUAL" = "nvim";
              };

              home.file.".bash_profile".text = ''
                # Set zsh has the default shell if it isn't already
                export SHELL=`which zsh`
                [ -z "$ZSH_VERSION" ] && exec "$SHELL"
              '';

            });
        };

      };
    };
}

