{
  description = "Firefox";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    nur.url = "flake:nur";
  };

  outputs = { self, nixpkgs, nur, ... }: {
    home = { config, lib, pkgs, ... }: {
      programs.firefox = {
        enable = true;

        package = pkgs.firefox.override {
          cfg = {
            enablePlasmaBrowserIntegration = true;
          };
        };

        profiles.default = {
          id = 0;
          settings = {
            "extensions.autoDisableScopes" = 0;

            "browser.search.defaultenginename" = "Google";
            "browser.search.selectedEngine" = "Google";
            "browser.urlbar.placeholderName" = "Google";
            "browser.search.region" = "US";

            "browser.uidensity" = 1;
            "browser.search.openintab" = true;
            "xpinstall.signatures.required" = false;
            "extensions.update.enabled" = false;

            "browser.display.use_document_fonts" = true;
            "pdfjs.disabled" = true;
            "media.videocontrols.picture-in-picture.enabled" = true;

            "widget.non-native-theme.enabled" = false;

            # "browser.newtabpage.enabled" = false;
            # "browser.startup.homepage" = "about:blank";

            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;

            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "network.allow-experiments" = false;
          };
        };

        extensions = let
         nurpkgs = import nixpkgs { system = pkgs.system; overlays = [ nur.overlay ]; };
         in with nurpkgs.nur.repos.rycee.firefox-addons; [
           ublock-origin
           return-youtube-dislikes
           sponsorblock
           plasma-integration
           greasemonkey
           no-pdf-download
         ];
      };

    };
  };
}
