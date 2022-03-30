{
  description = "Command Line Interface";

  inputs = {
    zsh-syntax-highlighting = { url = "github:zsh-users/zsh-syntax-highlighting"; flake = false; };

    nvim = {
      url = "github:mbund/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, ... }@inputs: {
    home = { pkgs, ... }:
      let
        masterpkgs = import inputs.nixpkgs-master {
          system = pkgs.system;
        };
      in
      {
        home.packages = with pkgs; [
          neofetch
          file
          autojump
          fzf
          ncdu
          lynx
          lazygit
          curl
          wget
          zip
          unzip
          xclip
          htop
          ripgrep
          inputs.nvim.defaultPackage.${pkgs.system}

          (nerdfonts.override {
            fonts = [
              "SourceCodePro" # Nerdfonts: Sauce Code Pro -> Source Code Pro
              "Hasklig" # Nerdfonts: Hasklug -> Hasklig -> Source Code Pro with ligatures
            ];
          })
        ];

        programs.lf = {
          enable = true;

          previewer.source = pkgs.writeShellScript "pv.sh" ''
            #!/bin/sh
            case "$1" in
                *.tar*) ${pkgs.gnutar}/bin/tar tf "$1";;
                *.zip) ${pkgs.unzip}/bin/unzip -l "$1";;
                *.rar) ${pkgs.p7zip}/bin/7z l "$1";;
                *.7z) ${pkgs.p7zip}/bin/7z l "$1";;
                *.pdf) ${pkgs.poppler_utils}/bin/pdftotext "$1" -;;
                *) ${pkgs.highlight}/bin/highlight -O ansi "$1" || ${pkgs.coreutils}/bin/cat "$1";;
            esac
          '';
        };

        programs.tmux = {
          enable = true;

          plugins = with pkgs.tmuxPlugins; [ resurrect ];

          extraConfig = ''
            unbind C-b
            set -g prefix C-a
            bind C-a send-prefix

            set -s escape-time 0
            set -g history-limit 50000

            set -g base-index 1
            setw -g pane-base-index 1

            set-option -g default-terminal "screen-256color"

            set-option -g default-shell ${pkgs.zsh}/bin/zsh
          '';
        };

        programs.zsh = {
          enable = true;
          dotDir = ".config/zsh";

          enableCompletion = true;
          enableAutosuggestions = true;
          oh-my-zsh = {
            enable = true;
            plugins = [ "git" "autojump" "vi-mode" ];
          };

          plugins = [
            {
              name = "zsh-syntax-highlighting";
              src = inputs.zsh-syntax-highlighting;
            }
          ];

          shellGlobalAliases = {
            "v" = "nvim";
            "vimdiff" = "nvim -d";
            "lg" = "lazygit";
            "UUID" = "$(uuidgen | tr -d \\n)";
          };

          initExtra = ''
            # Enable vi mode
            bindkey -v
          '';
        };

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        programs.starship = {
          enable = true;
          settings = {
            format = pkgs.lib.concatStrings [
              "$username"
              "$hostname"
              "$directory"
              "$git_branch"
              "$git_state"
              "$git_status"
              "$env_var"
              "$cmd_duration"
              "$line_break"
              "$jobs"
              "$battery"
              "$character"
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
              error_symbol = "[λ](bold red)";
              vicmd_symbol = "[λ](bold yellow)";
            };
            env_var.CURRENT_PROJECT = {
              variable = "CURRENT_PROJECT";
              format = "[❆$env_value](bold blue) ";
            };
            package.disabled = true;
          };
        };

      };
  };

}

