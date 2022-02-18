{
  description = "Command Line Interface";

  inputs = {
    zsh-syntax-highlighting = { url = "github:zsh-users/zsh-syntax-highlighting"; flake = false; };

    cmp-npm = { url = "github:David-Kunz/cmp-npm"; flake = false; };
    diagnosticls-configs-nvim = { url = "github:creativenull/diagnosticls-configs-nvim"; flake = false; };
    vim-windowswap = { url = "github:wesQ3/vim-windowswap"; flake = false; };
    zen-mode-nvim = { url = "github:folke/zen-mode.nvim"; flake = false; };
  };

  outputs = { self, ... } @ inputs: {
    home = { pkgs, ... }: {
      home.packages = with pkgs; [
        ranger
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

        (nerdfonts.override { fonts = [ "Hasklig" ]; })
      ];

      fonts.fontconfig.enable = true;

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

          "UUID" = "$(uuidgen | tr -d \\n)";
        };

        initExtra = ''
          # Enable vi mode
          bindkey -v
        '';
      };

      programs.neovim = {
        enable = true;
        extraConfig = ''
          source ~/nix-home/cli/init.vim
        '';

        extraPackages = with pkgs; [
          neovim-remote
          gcc # a c compiler is required for nvim-treesitter
          tree-sitter
          xclip

          rnix-lsp
          haskell-language-server
          nodePackages.bash-language-server
          nodePackages.vim-language-server
        ];

        plugins = with pkgs.vimPlugins; let
            pluginWithDeps = plugin: deps: plugin.overrideAttrs (_: { dependencies = deps; });
            externalPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;
          in [
            # themeing
            wal-vim
            nvim-base16
            lualine-nvim
            nvim-web-devicons
            dashboard-nvim
            bufferline-nvim
            gitsigns-nvim
            dracula-vim
            nvim-treesitter
            nvim-colorizer-lua
            vim-highlightedyank
            limelight-vim
            dressing-nvim

            # motions, remaps, text-editing improvements
            vim-sneak
            vim-commentary
            vim-indent-object
            vim-textobj-user
            vim-sort-motion
            vim-exchange
            vim-unimpaired
            vim-surround
            vim-repeat
            nvim-autopairs
            vim-sleuth
            emmet-vim

            # misc
            vim-fugitive
            undotree
            direnv-vim
            vim-tmux-navigator
            vimux
            vimwiki
            nvim-tree-lua
            vim-projectionist
            vim-eunuch
            editorconfig-vim
            vim-startuptime
            wilder-nvim
            (externalPlugin { pname = "vim-windowswap"; version = "master"; src = inputs.vim-windowswap; })
            (externalPlugin { pname = "zen-mode-nvim"; version = "master"; src = inputs.zen-mode-nvim; })

            # file navigation
            harpoon
            popup-nvim
            plenary-nvim
            telescope-nvim
            telescope-fzf-native-nvim
            telescope-file-browser-nvim

            # lsp
            nvim-lspconfig
            nvim-lsputils
            trouble-nvim
            lspkind-nvim
            nvim-cmp
            cmp-buffer
            cmp-path
            cmp-nvim-lsp
            luasnip
            cmp_luasnip
            vim-jsx-pretty
            vim-nix
            (externalPlugin { pname = "cmp-npm"; version = "master"; src = inputs.cmp-npm; })
            (externalPlugin { pname = "diagnosticls-configs-nvim"; version = "master"; src = inputs.diagnosticls-configs-nvim; })
          ];
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.starship = {
        enable = true;
        settings = {
          format = pkgs.lib.concatStrings [
            "$username" "$hostname" "$directory"
            "$git_branch" "$git_state" "$git_status"
            "$env_var"
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
