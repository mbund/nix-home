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

  systemd.user.services.latte-dock = {
    Unit = {
      Description = "Home-manager Latte Dock host";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    
    Service = {
      ExecStart = let
        script = pkgs.writeShellScript "latte-start.sh" ''
          ${pkgs.coreutils}/bin/cp -f ${./HomeManagerDock.layout.latte} /home/mbund/.config/latte/HomeManagerDock.layout.latte
          ${pkgs.latte-dock}/bin/latte-dock --layout HomeManagerDock --replace
        '';
      in "${script}";
    };
  };

  home.stateVersion = "21.11";

}
