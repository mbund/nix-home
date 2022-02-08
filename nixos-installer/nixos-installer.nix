{ lib, pkgs, inputs, ... }:
{
  imports = with inputs; [
    common.home
    cli.home
    plasma.home
    firefox.home
  ];

  home.packages = with pkgs; [
    zip
    unzip
    mpv
    vlc
    # gparted
    # gptfdisk
  ];

  home.sessionVariables = {
    "EDITOR" = "neovim";
    "VISUAL" = "neovim";
  };

  home.stateVersion = "21.11";

}
