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
  };

  outputs = { self, ... }@inputs: with inputs; {
    homeConfigurations =
      mbund.homeConfigurations inputs;

    homeNixOSModules =
      mbund.homeNixOSModules inputs;

  };
}

