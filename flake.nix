{
  description = "Conglomeration of home-manager configurations";

  inputs = {
    # users
    mbund.url = "./mbund";

    # components
    common.url = "./common";
    cli.url = "./cli";
    plasma.url = "./plasma";
    firefox.url = "./firefox";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: with inputs; {
    homeConfigurations =
      mbund.homeConfigurations inputs;

    homeNixOSModules =
      mbund.homeNixOSModules inputs;

  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          rnix-lsp
        ];
      };
    }
  );
}

