{ lib, pkgs, inputs, ... }:
{
  imports = with inputs; [
    common.home
    cli.home
    plasma.home
    firefox.home
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam" "steam-original" "steam-runtime" # for lutris
    "vscode" "vscode-extension-ms-vsliveshare-vsliveshare"
    "discord"
    "zoom"
    "spotify-unwrapped"
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [ obs-nvfbc ];
  };

  home.packages = with pkgs; [
    (lutris.overrideAttrs (_: { buildInputs = [ xdelta ]; }))
    
    zip
    unzip
    mpv
    vlc
    chromium
    virt-manager
    godot
    gparted
    discord
    spotify-tui
    spotify-unwrapped
    krita
    inkscape
    gimp
    onlyoffice-bin
    zoom
    aspell
    aspellDicts.en
  ];

  home.sessionVariables = {
    "EDITOR" = "neovim";
    "VISUAL" = "neovim";
  };

}
