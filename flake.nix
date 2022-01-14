{
  description = "Conglomeration of home-manager configurations";
  
  inputs = {
    marshmellow-roaster.url = "./marshmellow-roaster";
  };

  outputs = { self, ... } @ inputs: {
    homeConfigurations = inputs.marshmellow-roaster.homeConfigurations;
  };
}
