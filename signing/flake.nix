{
  description = "Common";

  outputs = { self, ... }@inputs: {
    home = { config, lib, pkgs, ... }: {

      programs.git = {
        enable = true;

        signing = {
          key = "6C8949C0713C5B3C";
          signByDefault = true;
        };

        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = false;
          credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
        };

        ignores = [
          "*.swp"
          ".direnv/"
          ".envrc"
          ".vscode/"
          ".mygitignore"
        ];

        userEmail = "25110595+mbund@users.noreply.github.com";
        userName = "mbund";
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

