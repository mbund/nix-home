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
        latte-dock
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
            Windows = {
              RollOverDesktops = false;
              BorderlessMaximizedWindows = false;
            };
          };
          kdeglobals.KDE.SingleClick = false;
          kcminputrc = {
            Keyboard.NumLock = 0;
            Mouse.XLbInptAccelProfileFlat = true;
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
