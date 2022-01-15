{
  description = "Command Line Interface";

  inputs = {
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting";
      flake = false;
    };
  };

  outputs = { self, ... } @ inputs: {
    home = { config, lib, pkgs, ... }: {
      home.packages = with pkgs; [
        ranger
        neofetch
        neovim
        file
        thefuck
        autojump

        (nerdfonts.override { fonts = [ "Hasklig" ]; })
      ];

      fonts.fontconfig.enable = true;

      programs.zsh = {
        enable = true;
        dotDir = ".config/zsh";

        enableCompletion = true;
        enableAutosuggestions = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "autojump" ];
        };

        plugins = [
          {
            name = "zsh-syntax-highlighting";
            src = inputs.zsh-syntax-highlighting;
          }
        ];

        initExtra = ''
          eval $(thefuck --alias)
        '';
      };

      programs.starship = {
        enable = true;
        settings = {
          format = pkgs.lib.concatStrings [
            "$username" "$hostname" "$directory"
            "$git_branch" "$git_state" "$git_status"
            "$cmd_duration"
            "$line_break"
            "$jobs" "$battery" "$character"
          ];
          cmd_duration = {
            min_time = 1;
            format = "in [$duration](bold yellow)";
          };
          directory = {
            truncation_length = 10;
          };
          git_branch = {
            symbol = "";
            format = "on [$symbol$branch]($style) ";
          };
          git_status = {
            ahead = "⇡$count";
            diverged = "⇕⇡$ahead_count⇣$behind_count";
            behind = "⇣$count";
            modified = "*";
          };
          character = {
            success_symbol = "[λ](bold green)";
          };
          package.disabled = true;
        };
      };

      home.file.".bashrc".text = ''
        # Set zsh has the default shell if it isn't already
        export SHELL=`which zsh`
        [ -z "$ZSH_VERSION" ] && exec "$SHELL"
      '';
    };
  };
}
