{
  description = "marshmellow-roaster home-manager";
  
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
      marshmellow-roaster-mbund = inputs.home-manager.lib.homeManagerConfiguration {
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
            git
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
