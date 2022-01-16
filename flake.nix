{
  description = "Conglomeration of home-manager configurations";
  
  inputs = {
    marshmellow-roaster.url = "./marshmellow-roaster";
    desktop.url = "./desktop";
  };

  outputs = { self, ... } @ inputs: {
    homeConfigurations = {
      marshmellow-roaster = inputs.marshmellow-roaster.homeConfigurations;
      desktop = inputs.desktop.homeConfigurations;
    };
  };
}
