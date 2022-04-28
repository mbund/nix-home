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
  };

  outputs = { self, home-manager, ... }@mbund-inputs:
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
          "discord"
        ];
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

              oneshotPkg = input: import input { inherit system; config = { allowUnfree = true; allowBroken = true; }; };
            in
            { config, ... }: ({
              imports = with inputs; [
                common.home
                cli.home
                plasma.home
                firefox.home
                signing.home
              ];

              programs.obs-studio = {
                enable = true;
                plugins = with pinned-pkgs.obs-studio-plugins; [ obs-nvfbc ];
              };

              programs.chromium = {
                enable = true;
                commandLineArgs = [
                  "--password-store=kwallet5"
                ];
              };

              fonts.fontconfig.enable = true;

              home.packages = with pinned-pkgs; [
                # audio/video
                calf
                ardour
                lmms
                qpwgraph
                playerctl
                vlc
                audacity

                # social/entertainment
                ferdi
                master-pkgs.discord
                spotify-unwrapped
                (lutris.overrideAttrs (_: { buildInputs = [ xdelta ]; }))

                # art
                krita
                inkscape
                gimp
                blender

                # school/productivity
                onlyoffice-bin
                zoom
                gnucash
                zathura
                graphviz
                xdot
                dot2tex
                liberation_ttf

                # programming
                vscode-fhs
                godot
                ghidra

                # system
                gparted
                virt-manager

                # misc
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
                firefox.home
                de.home
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

