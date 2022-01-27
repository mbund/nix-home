{
  description = "mbund's home-manager configuration for all systems";
  
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.url = "flake:nixpkgs";
    };

    common.url = "flake:home?dir=common";
    cli.url = "flake:home?dir=cli";
    plasma.url = "flake:home?dir=plasma";
    firefox.url = "flake:home?dir=firefox";
  };

  outputs = { self, ... } @ inputs: {
    homeConfigurations = {
      
      "mbund@mbund-desktop" = inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        homeDirectory = "/home/mbund";
        username = "mbund";
        configuration = { config, lib, pkgs, ... }:
        ({
          imports = with inputs; [
            common.home
            cli.home
            plasma.home
            firefox.home
          ];

          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "vscode"
            "discord"
            "zoom"
            "spotify-unwrapped"
            "vscode-extension-ms-vsliveshare-vsliveshare"
          ];

          programs.vscode = {
            enable = true;
            package = pkgs.vscode;
            extensions = with pkgs.vscode-extensions; [ ms-vsliveshare.vsliveshare ];
          };

          programs.obs-studio = {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [ obs-nvfbc ];
          };

          home.packages = with pkgs; [
            zip
            unzip
            mpv
            vlc
            chromium
            virt-manager
            godot
            gparted
            discord
            spotify-tui
            spotify-unwrapped
            krita
            inkscape
            gimp
            onlyoffice-bin
            zoom
            aspell
            # aspellDicts.en
          ];

        });
      };

      "mbund@marshmellow-roaster" = inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        homeDirectory = "/home/mbund";
        username = "mbund";
        configuration = { config, lib, pkgs, ... }:
        ({
          imports = with inputs; [
            common.home
            cli.home
            plasma.home
          ];

          home.packages = with pkgs; [
            firefox
            vscodium
            virt-manager
            godot
            gparted
          ];

        });
      };

    };
  };
}
