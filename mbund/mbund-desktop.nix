{ config, lib, pkgs, inputs, ... }:
let

  masterpkgs = import inputs.nixpkgs-master {
    system = pkgs.system;

    config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "discord"
    ];
  };

in
{
  imports = with inputs; [
    common.home
    cli.home
    plasma.home
    firefox.home
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    # steam is required for lutris
    "steam"
    "steam-original"
    "steam-runtime"

    "code"
    "vscode"

    "zoom"

    "spotify-unwrapped"
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [ obs-nvfbc ];
  };

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--password-store=kwallet5"
    ];
  };

  home.packages = with pkgs; [
    (lutris.overrideAttrs (_: { buildInputs = [ xdelta ]; }))

    calf
    ardour
    qpwgraph
    playerctl
    mpv
    vlc
    virt-manager
    godot
    gparted
    masterpkgs.discord
    spotify-unwrapped
    krita
    inkscape
    gimp
    onlyoffice-bin
    zoom
    aspell
    aspellDicts.en
    vscode-fhs
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
    "VISUAL" = "nvim";
  };

  systemd.user.services.home-manager-latte-dock = {
    Unit = {
      Description = "Home-manager Latte Dock host";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart =
        let
          script = pkgs.writeShellScript "latte-start.sh" ''
            ${pkgs.coreutils}/bin/cp -f ${./HomeManagerDock.layout.latte} ${config.home.homeDirectory}/.config/latte/HomeManagerDock.layout.latte
            ${masterpkgs.latte-dock}/bin/latte-dock --layout HomeManagerDock --replace
          '';
        in
        "${script}";
    };
  };

  home.stateVersion = "21.11";

}




