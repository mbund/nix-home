{ pkgs, inputs, ... }:
{
  imports = with inputs; [
    common.home
    cli.home
    plasma.home
    firefox.home
  ];

  home.packages = with pkgs; [
    vscodium
    virt-manager
    godot
    gparted
  ];

  home.stateVersion = "21.11";

}
