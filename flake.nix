{
  description = "Conglomeration of home-manager configurations";
  
  inputs = {
    # users
    mbund.url = "./mbund";
    nixos-installer.url = "./nixos-installer";

    # components
    common.url = "./common";
    cli.url = "./cli";
    plasma.url = "./plasma";
    firefox.url = "./firefox";
  };

  outputs = { self, ... }@inputs: with inputs; {
    homeConfigurations =
      mbund.homeConfigurations //
      nixos-installer.homeConfigurations;

    homeNixOSModules =
      mbund.homeNixOSModules //
      nixos-installer.homeNixOSModules;

  };
}
