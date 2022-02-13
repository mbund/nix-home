{ config, lib, pkgs, inputs, ... }:
{
  imports = with inputs; [
    common.home
    cli.home
    plasma.home
    firefox.home
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam" "steam-original" "steam-runtime" # for lutris
    "code" "vscode"
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
    aspell aspellDicts.en
    vscode-fhs
  ];

  home.sessionVariables = {
    "EDITOR" = "neovim";
    "VISUAL" = "neovim";
  };

  systemd.user.services.home-manager-latte-dock = {
    Unit = {
      Description = "Home-manager Latte Dock host";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    
    Service = {
      ExecStart = let
        script = pkgs.writeShellScript "latte-start.sh" ''
          ${pkgs.coreutils}/bin/cp -f ${./HomeManagerDock.layout.latte} ${config.home.homeDirectory}/.config/latte/HomeManagerDock.layout.latte
          ${pkgs.latte-dock}/bin/latte-dock --layout HomeManagerDock --replace
        '';
      in "${script}";
    };
  };

  home.stateVersion = "21.11";

}
