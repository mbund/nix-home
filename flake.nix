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

  outputs = { self, ... } @ inputs: {
    homeConfigurations = inputs.mbund.homeConfigurations;
    configurations = inputs.mbund.configurations;
  };
}
