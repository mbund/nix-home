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
    "vscode"
    "discord"
    "zoom"
    "spotify-unwrapped"
    "vscode-extension-ms-vsliveshare-vsliveshare"
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [ ms-vsliveshare.vsliveshare ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [ obs-nvfbc ];
  };

  home.packages = with pkgs; [
    lutris xdelta
    # (lutris.overrideAttrs (_: { dependencies = [ xdelta ]; }))
    # pluginWithDeps = plugin: deps: plugin.overrideAttrs (_: { dependencies = deps; });
    
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
