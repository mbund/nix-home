{
  description = "default nixos user home-manager configuration";
  
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    common.follows = "common";
    cli.follows = "cli";
    plasma.follows = "plasma";
    firefox.follows = "firefox";

    nixpkgs.url = "flake:nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      homes = [
        { system = "x86_64-linux"; user = "nixos@nixos-installer"; }
      ];

      builder = f: builtins.listToAttrs (builtins.map (home: {
        name = home.user;

        value = let
          splitUser = nixpkgs.lib.splitString "@" home.user;
          configPath = ./. + "/${builtins.elemAt splitUser 1}.nix";
        in
          assert nixpkgs.lib.assertMsg (builtins.length splitUser == 2) "invalid name: ${home.user}";
          assert nixpkgs.lib.assertMsg (builtins.pathExists configPath) "path does not exist: ${builtins.toString configPath}";

          f { inherit home splitUser configPath; };
      }) homes);
    in {

      homeConfigurations = builder ({ home, splitUser, configPath }:
        home-manager.lib.homeManagerConfiguration {
          system = home.system;
          stateVersion = "21.11";
          homeDirectory = "/home/${builtins.head splitUser}";
          username = builtins.head splitUser;
          configuration = import configPath;
          extraSpecialArgs = { inherit inputs; };
        }
      );

      homeNixOSModules = builder ({ home, splitUser, configPath }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.${builtins.head splitUser} = import configPath;
        };
      });

  };
}
