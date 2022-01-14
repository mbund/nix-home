{
  description = "Common";

  outputs = { self, ... }: {
    home = { config, lib, pkgs, ... }: {
      programs.home-manager.enable = true;
    };
  };
}
