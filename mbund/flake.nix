{
  description = "mbund's home-manager configuration for all systems";
  
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.url = "nixpkgs";
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
        { system = "x86_64-linux"; user = "mbund@mbund-desktop"; }
        { system = "x86_64-linux"; user = "mbund@marshmellow-roaster"; }
        { system = "x86_64-linux"; user = "mbund@live-iso"; }
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
          homeDirectory = "/home/${builtins.head splitUser}";
          username = builtins.head splitUser;
          configuration = import configPath;
          extraSpecialArgs = { inherit inputs; };
        });

      nixosModules = builder ({ home, splitUser, configPath }:
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${builtins.head splitUser} = import configPath;
        });

  };
}
