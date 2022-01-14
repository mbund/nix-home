{
  description = "mbund's home-manager profile";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cli.url = "./cli";
  };

  outputs = { self, ... }@inputs: {
    homeConfigurations = {
      mbund = inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        homeDirectory = "/home/mbund";
        username = "mbund";
        configuration = { config, lib, pkgs, ... }:
        ({
          imports = with inputs; [ cli.home ];

          home.packages = with pkgs; [
            git
            firefox
            neovim
            neofetch
            vscodium
            file
	          virt-manager
	          godot
          ];

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

          programs.home-manager.enable = true;
        });
      };
    };
  };
}
