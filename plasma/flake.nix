{
  description = "KDE Plasma";

  outputs = { self, ... }: {
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

      home.packages = with pkgs; [
        krfb
        krdc
        ark
        latte-dock

        (pkgs.writeShellApplication {
          name = "kde-chameleon";
          runtimeInputs = with pkgs; [ dbus pywal jq ];
          text = builtins.readFile ./kde-chameleon.sh;
        })
      ];
      
      home.activation.kdeConfigs = let
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
              Name_1 = "1";
              Name_2 = "2";
              Name_3 = "3";
              Name_4 = "4";
              Number = 4;
              Rows = 1;
            };

            # Workspace Behavior -> Desktop Effects
            Plugins = {
              blurEnable = true;
              contrastEnable = false;
            };

            TabBox = { # Task Switcher
              # Visualization
              LayoutName = "thumbnail_grid";
            };

            Windows = {
              RollOverDesktops = false;
              BorderlessMaximizedWindows = false;
            };
          };

          kdeglobals.KDE.SingleClick = false;

          kcminputrc = { # Input Devices
            Keyboard.NumLock = 0; # Keyboard -> NumLock on Plasma Startup -> Turn on
            Mouse.XLbInptAccelProfileFlat = true; # Mouse -> Acceleration profile -> Flat
          };

          krunnerrc = { # Search -> KRunner
            General.FreeFloating = true; # Position on screen -> Center
          };
          
          klaunchrc = { # Appearance -> Launch Feedback
            # No Feedback
            BusyCursorSettings.Bouncing = false;
            FeedbackStyle.BusyCursor = false;
          };

          kscreenlockerrc.Daemon = { # Workspace -> Screen Locking
            Autolock = false;
            LockOnResume = false;
          };
          
          ksmserverrc.General = { # Startup and Shutdown -> Desktop Session
            confirmLogout = false;
            loginMode = "emptySession";
            offerShutdown = false;
          };

          kglobalshortcutsrc = {
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

            };
          };
        };
        lines = lib.flatten (lib.mapAttrsToList (file: groups:
          lib.mapAttrsToList (group: keys:
            lib.mapAttrsToList (key: value:
              "test -f ~/.config/'${file}' && ${pkgs.libsForQt5.kconfig}/bin/kwriteconfig5 --file ~/.config/'${file}' --group '${group}' --key '${key}' ${
                toValue value
              }") keys) groups) configs);
      in
        lib.hm.dag.entryAfter [ "writeBoundary" ] (builtins.concatStringsSep "\n" lines);

    };
  };
}
