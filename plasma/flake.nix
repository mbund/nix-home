{
  description = "KDE Plasma";

  inputs = {
    one-dark-kde-theme = { url = "github:Prayag2/kde_onedark"; flake = false; };
  };

  outputs = { self, ... }@inputs: {
    home = { config, lib, pkgs, ... }: {
      gtk = {
        enable = true;
        theme = {
          name = "Breeze";
          package = pkgs.gnome-breeze;
        };

        iconTheme = {
          name = "Breeze";
          package = pkgs.gnome.adwaita-icon-theme;
        };
      };

      home.file.".local/share/color-schemes/One-Dark-Blue.colors".source = inputs.one-dark-kde-theme + "/color-schemes/One-Dark/One-Dark-Blue.colors";
      home.file.".local/share/color-schemes/One-Dark-Green.colors".source = inputs.one-dark-kde-theme + "/color-schemes/One-Dark/One-Dark-Green.colors";
      home.file.".local/share/color-schemes/One-Dark-Red.colors".source = inputs.one-dark-kde-theme + "/color-schemes/One-Dark/One-Dark-Red.colors";
      home.file.".local/share/color-schemes/One-Dark-Yellow.colors".source = inputs.one-dark-kde-theme + "/color-schemes/One-Dark/One-Dark-Yellow.colors";

      services.kdeconnect.enable = true;

      home.packages = with pkgs; [
        krfb
        krdc
        ark
        latte-dock
        scrcpy
        libsForQt5.bismuth

        (pkgs.writeShellApplication {
          name = "kde-chameleon";
          runtimeInputs = with pkgs; [ libsForQt5.qt5.qttools dbus pywal jq ];
          text = builtins.readFile ./kde-chameleon.sh;
        })
      ];

      systemd.user.services.home-manager-kde-config = {
        Unit = {
          Description = "Home-manager KDE configuration writing";
        };

        Install = {
          WantedBy = [ "plasma-kglobalaccel.service" "plasma-kwin_x11.service" ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStartPost =
            let
              script = pkgs.writeShellScript "restart-kde.sh" ''
                systemctl restart --user plasma-kglobalaccel.service;
                systemctl restart --user plasma-kwin_x11.service
              ''; in
            "${script}";

          ExecStart =
            let
              toValue = v:
                if v == null then
                  "--delete"
                else if builtins.isString v then
                  "'" + v + "'"
                else if builtins.isBool v then
                  "--type bool " + lib.boolToString v
                else if builtins.isInt v then
                  builtins.toString v
                else
                  builtins.abort ("Unknown value type: " ++ builtins.toString v);
              configs = {
                kwinrc = {
                  Compositing = {
                    GLCore = true;
                    OpenGLIsUnsafe = false;
                    MaxFPS = 144;
                    RefreshRate = 144;
                  };

                  Desktops = {
                    Id_1 = "7c099d80-a16d-4133-b1f8-d4fd92e73e71";
                    Id_2 = "6ccf0ea5-46df-4f08-ab39-b1fa4746ca49";
                    Id_3 = "2e95628f-98b9-4a00-96dd-d2184b8083c2";
                    Id_4 = "0a26cb7c-f464-4c43-b14a-46bb2f29ebad";
                    Id_5 = "74e4581d-c2bd-4752-9b74-bd120c4ac95e";
                    Id_6 = "083b5330-5262-4a37-9ef6-89d7752294b1";
                    Id_7 = "e78631ff-98ac-4bd6-a2b6-1bca799f75c7";
                    Id_8 = "760b6320-d6c5-4623-a0e7-8e0c676de3a2";
                    Id_9 = "7f9dbd6d-edfe-47b6-bafb-1f8e14562778";
                    Id_10 = "5d70cb18-c505-4811-9f42-bf3cbd37d5b0";
                    Name_1 = "1";
                    Name_2 = "2";
                    Name_3 = "3";
                    Name_4 = "4";
                    Name_5 = "5";
                    Name_6 = "6";
                    Name_7 = "7";
                    Name_8 = "8";
                    Name_9 = "9";
                    Name_10 = "10";
                    Number = 10;
                    Rows = 1;
                  };

                  # Workspace Behavior -> Desktop Effects
                  Plugins = {
                    slideEnabled = false;
                    kwin4_effect_shapecornersEnabled = true;
                  };

                  TabBox = {
                    # Task Switcher
                    # Visualization
                    LayoutName = "thumbnail_grid";
                  };

                  Windows = {
                    RollOverDesktops = false;
                    BorderlessMaximizedWindows = false;
                  };
                };

                kdeglobals.KDE.SingleClick = false;

                kcminputrc = {
                  # Input Devices
                  Keyboard.NumLock = 0; # Keyboard -> NumLock on Plasma Startup -> Turn on
                  Mouse.XLbInptAccelProfileFlat = true; # Mouse -> Acceleration profile -> Flat
                };

                krunnerrc = {
                  # Search -> KRunner
                  General.FreeFloating = true; # Position on screen -> Center
                };

                klaunchrc = {
                  # Appearance -> Launch Feedback
                  # No Feedback
                  BusyCursorSettings.Bouncing = false;
                  FeedbackStyle.BusyCursor = false;
                };

                kscreenlockerrc.Daemon = {
                  # Workspace -> Screen Locking
                  Autolock = false;
                  LockOnResume = false;
                };

                ksmserverrc.General = {
                  # Startup and Shutdown -> Desktop Session
                  confirmLogout = false;
                  loginMode = "emptySession";
                  offerShutdown = false;
                };

                kglobalshortcutsrc = {
                  plasmashell = {
                    "activate task manager entry 6" = "none,Meta+6,Activate Task Manager Entry 6";
                    "activate task manager entry 7" = "none,Meta+7,Activate Task Manager Entry 7";
                    "activate task manager entry 8" = "none,Meta+8,Activate Task Manager Entry 8";
                    "activate task manager entry 9" = "none,Meta+9,Activate Task Manager Entry 9";
                    "activate task manager entry 10" = "none,Meta+0,Activate Task Manager Entry 10";
                  };
                  kwin = {
                    "Window Close" = "Meta+C,Alt+F4,Close Window";
                    "Window Fullscreen" = "Meta+Shift+F,none,Make Window Fullscreen";
                    "Window Maximize" = "Meta+F,Meta+PgUp,Maximize Window";
                    "Window Minimize" = "Meta+Alt+F,Meta+PgDown,Minimize Window";
                    "Window On All Desktops" = "Meta+V,none,Keep Window on All Desktops";

                    "Switch to Desktop 1" = "Meta+1,Ctrl+F1,Switch to Desktop 1";
                    "Switch to Desktop 2" = "Meta+2,Ctrl+F2,Switch to Desktop 2";
                    "Switch to Desktop 3" = "Meta+3,Ctrl+F3,Switch to Desktop 3";
                    "Switch to Desktop 4" = "Meta+4,Ctrl+F4,Switch to Desktop 4";
                    "Switch to Desktop 5" = "Meta+5,none,Switch to Desktop 5";
                    "Switch to Desktop 6" = "Meta+6,none,Switch to Desktop 6";
                    "Switch to Desktop 7" = "Meta+7,none,Switch to Desktop 7";
                    "Switch to Desktop 8" = "Meta+8,none,Switch to Desktop 8";
                    "Switch to Desktop 9" = "Meta+9,none,Switch to Desktop 9";
                    "Switch to Desktop 10" = "Meta+0,none,Switch to Desktop 10";

                    "Switch to Screen 0" = "Meta+A,none,Switch to Screen 0";
                    "Switch to Screen 1" = "Meta+S,none,Switch to Screen 1";
                    "Switch to Screen 2" = "Meta+D,none,Switch to Screen 2";
                    "Window to Screen 0" = "Meta+Shift+A,none,Window to Screen 0";
                    "Window to Screen 1" = "Meta+Shift+S,none,Window to Screen 1";
                    "Window to Screen 2" = "Meta+Shift+D,none,Window to Screen 2";

                    "Window to Desktop 1" = "Meta+!,none,Window to Desktop 1";
                    "Window to Desktop 2" = "Meta+@,none,Window to Desktop 2";
                    "Window to Desktop 3" = "Meta+#,none,Window to Desktop 3";
                    "Window to Desktop 4" = "Meta+$,none,Window to Desktop 4";
                    "Window to Desktop 5" = "Meta+%,none,Window to Desktop 5";
                    "Window to Desktop 6" = "Meta+^,none,Window to Desktop 6";
                    "Window to Desktop 7" = "Meta+&,none,Window to Desktop 7";
                    "Window to Desktop 8" = "Meta+*,none,Window to Desktop 8";
                    "Window to Desktop 9" = "Meta+(,none,Window to Desktop 9";

                  };
                };
              };

              lines = lib.flatten (lib.mapAttrsToList
                (file: groups:
                  lib.mapAttrsToList
                    (group: keys:
                      lib.mapAttrsToList
                        (key: value:
                          "test -f ${config.home.homeDirectory}/.config/'${file}' && ${pkgs.libsForQt5.kconfig}/bin/kwriteconfig5 --file ${config.home.homeDirectory}/.config/'${file}' --group '${group}' --key '${key}' ${
                    toValue value
                  }")
                        keys)
                    groups)
                configs);

              script = pkgs.writeShellScript "write-kde-configuration.sh" ''
                ${pkgs.coreutils}/bin/touch ${config.home.homeDirectory}/.config/shapecorners.conf
                ${builtins.concatStringsSep "\n" lines}
              '';
            in
            "${script}";

        };
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
              script = stable-pkgs.writeShellScript "latte-start.sh" ''
                ${stable-pkgs.coreutils}/bin/cp -f ${./HomeManagerDock.layout.latte} ${config.home.homeDirectory}/.config/latte/HomeManagerDock.layout.latte
                ${master-pkgs.latte-dock}/bin/latte-dock --layout HomeManagerDock --replace
              '';
            in
            "${script}";
        };
      };

    };
  };
}

