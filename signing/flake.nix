{
  description = "Common";

  outputs = { self, ... }@inputs: {
    home = { config, lib, pkgs, ... }: {

      programs.git = {
        enable = true;

        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = false;
          # credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
        };

        ignores = [
          "*.swp"
          ".direnv/"
          ".envrc"
          ".vscode/"
          ".mygitignore"
        ];
      };

      programs.ssh = {
        enable = true;
        matchBlocks = {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = "${config.home.homeDirectory}/.ssh/github";
          };
        };
      };

      programs.password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      };

      programs.gpg.enable = true;

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };

    };
  };
}

