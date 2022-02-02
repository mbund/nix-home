{
  description = "KDE Plasma";

  inputs = {
    one-dark-kde-theme = { url = "github:Prayag2/kde_onedark"; flake = false; };
    fluent-icons = { url = "github:vinceliuice/Fluent-icon-theme"; flake = false; };
    kde-rounded-corners = { url = "github:matinlotfali/KDE-Rounded-Corners"; flake = false; };
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

      # home.file = builtins.listToAttrs (map (color: {
      #   name = ".local/share/color-schemes/${color}.colors";
      #   value = { "source" = inputs.one-dark-kde-theme + "/color-schemes/One-Dark/${color}.colors"; };
      # }) [ "One-Dark-Blue" "One-Dark-Green" "One-Dark-Red" "One-Dark-Yellow" ]);
      home.file.".local/share/color-schemes/One-Dark-Blue.colors".source = inputs.one-dark-kde-theme + "/color-schemes/One-Dark/One-Dark-Blue.colors";
      home.file.".local/share/icons/Fluent-Custom/64".source = inputs.fluent-icons + "/src/64";
      home.file.".local/share/icons/Fluent-Custom/scalable".source = inputs.fluent-icons + "/src/scalable";
      home.file.".local/share/icons/Fluent-Custom/symbolic".source = inputs.fluent-icons + "/src/symbolic";
      home.file.".local/share/icons/Fluent-Custom/index.theme".source = inputs.fluent-icons + "/src/index.theme";

      services.kdeconnect = {
        enable = true;
        indicator = true;
      };

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

        (pkgs.libsForQt5.callPackage({ mkDerivation }: mkDerivation) {} rec {
          name = "kde-rounded-corners";
          version = "0.0.1";

          #src = pkgs.fetchFromGitHub {
          #  owner = "matinlotfali";
          #  repo = "KDE-Rounded-Corners";
          #  rev = "8ad8f5f5eff9d1625abc57cb24dc484d51f0e1bd";
          #  sha256 = "sha256-N6DBsmHGTmLTKNxqgg7bn06BmLM2fLdtFG2AJo+benU=";
          #};
          src = inputs.kde-rounded-corners;
          nativeBuildInputs = with pkgs; [
            cmake
          ];
          buildInputs = with pkgs; [
            extra-cmake-modules
            libepoxy
            libsForQt5.kwin
            libsForQt5.qt5.qttools
            libsForQt5.qt5.qtx11extras
            libsForQt5.kdelibs4support
          ];

          preConfigure = ''
            local modulepath=$(kf5-config --install module)
            local datapath=$(kf5-config --install data)
            substituteInPlace CMakeLists.txt \
              --replace "\''${MODULEPATH}" "$out/''${modulepath#/nix/store/*/}" \
              --replace "\''${DATAPATH}"   "$out/''${datapath#/nix/store/*/}"
          '';

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
              Id_5 = "74e4581d-c2bd-4752-9b74-bd120c4ac95e";
              Id_6 = "083b5330-5262-4a37-9ef6-89d7752294b1";
              Id_7 = "e78631ff-98ac-4bd6-a2b6-1bca799f75c7";
              Id_8 = "760b6320-d6c5-4623-a0e7-8e0c676de3a2";
              Id_9 = "7f9dbd6d-edfe-47b6-bafb-1f8e14562778";
              Name_1 = "1";
              Name_2 = "2";
              Name_3 = "3";
              Name_4 = "4";
              Name_5 = "5";
              Name_6 = "6";
              Name_7 = "7";
              Name_8 = "8";
              Name_9 = "9";
              Number = 9;
              Rows = 1;
            };

            # Workspace Behavior -> Desktop Effects
            Plugins = {
              slideEnabled = false;
              kwin4_effect_shapecornersEnabled = true;
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

          "shapecorners.conf".General = {
            dsp = true;
            roundness = 3;
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
              "Switch to Desktop 7" = "Meta+7,none,Switch to Desktop 7";
              "Switch to Desktop 8" = "Meta+8,none,Switch to Desktop 8";
              "Switch to Desktop 9" = "Meta+9,none,Switch to Desktop 9";

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
