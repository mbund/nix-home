{
  description = "Command Line Interface";

  inputs = {
    nvim = {
      url = "github:mbund/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix/22.03";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixCargoIntegrations.inputs = {
          nixpkgs.follows = "nixpkgs";
          dream2nix.inputs.nixpkgs.follows = "nixpkgs";
        };
      };
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
        home.packages = with pkgs; with inputs; [
          neofetch
          file
          autojump
          fzf
          ncdu
          lynx
          lazygit
          curl
          jq
          wget
          zip
          unzip
          xclip
          htop
          ripgrep
          tmux
          rnix-lsp
          nixpkgs-fmt
          helix.defaultPackage.${system}
          # inputs.nvim.defaultPackage.${pkgs.system}

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

        # configure tmux
        home.file.".tmux.conf".source = ./tmux.conf;
        home.file.".tmux.conf.local".text =
          let
            check = pkgs.lib.types.package.check;
            pluginName = p: if check p then p.pname else p.plugin.pname;

            plugins = with pkgs.tmuxPlugins; [
              resurrect
            ];
          in
          ''
            ${builtins.readFile ./tmux.conf.local}

            # ============================================= #
            # Load plugins with Home Manager                #
            # --------------------------------------------- #
            ${(pkgs.lib.concatMapStringsSep "\n\n" (p: ''
              # ${pluginName p}
              # ---------------------
              ${p.extraConfig or ""}
              run-shell ${if check p then p.rtp else p.plugin.rtp}
            '') plugins)}
            # ============================================= #
          '';

        # configure helix
        home.file.".config/helix/config.toml".text = ''
          theme = "onedark"

          [editor]
          line-number = "relative"
        '';

        home.sessionVariables = {
          "EDITOR" = "hx";
          "VISUAL" = "hx";
        };

        programs.zsh = {
          enable = true;
          dotDir = ".config/zsh";

          enableCompletion = true;
          enableAutosuggestions = true;
          enableSyntaxHighlighting = true;
          oh-my-zsh = {
            enable = true;
            plugins = [ "git" "autojump" ];
          };

          shellAliases = {
            "v" = "nvim";
            "vimdiff" = "nvim -d";
            "lg" = "lazygit";
            "git-sign-github" = "git config user.name mbund && git config user.email 25110595+mbund@users.noreply.github.com && git config user.signingkey 6C8949C0713C5B3C";
          };

          shellGlobalAliases = {
            "UUID" = "$(uuidgen | tr -d \\n)";
          };

          initExtra = ''
            # Enable vi mode
            # bindkey -v
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
