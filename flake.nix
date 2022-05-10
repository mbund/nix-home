{
  description = "Conglomeration of home-manager configurations";

  inputs = {
    # users
    mbund.url = "./mbund";

    # components
    common.url = "./common";
    cli.url = "./cli";
    plasma.url = "./plasma";
    signing.url = "./signing";
    mbund-gnome.url = "./mbund-gnome";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: with inputs; {
    homeConfigurations =
      mbund.genHomeConfigurations inputs //
        { };

  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          rnix-lsp
          nixpkgs-fmt
        ];
      };
    }
  );
}
