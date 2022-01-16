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
          ];

          nixpkgs.config.allowUnfree = true;

          home.packages = with pkgs; [
            firefox
            vscodium
	          virt-manager
	          godot
            gparted
            discord
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
