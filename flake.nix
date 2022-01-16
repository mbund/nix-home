{
  description = "Conglomeration of home-manager configurations";
  
  inputs = {
    mbund.url = "./mbund";
  };

  outputs = { self, ... } @ inputs: {
    homeConfigurations = inputs.mbund.homeConfigurations;
  };
}
