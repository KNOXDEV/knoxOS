{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      extensions = {
        packages = with pkgs.firefox-addons; [
          onepassword-password-manager
          pay-by-privacy
        ];
      };

      # Best search for nix features, unfortunately
      bookmarks.settings = [
        {
          name = "MyNixOS Search";
          keyword = "!nix";
          url = "https://mynixos.com/search?q=%s";
        }
      ];
      bookmarks.force = true;

      settings = {
        # Disable about:config warning
        "browser.aboutConfig.showWarning" = false;
        # restore previous session
        "browser.startup.page" = 3;
        # blank new tabs
        "browser.newtabpage.enabled" = false;
        "browser.startup.homepage" = "chrome://browser/content/blanktab.html";

        # activity stream stuff
        "browser.newtabpage.activity-stream.showSearch" = false;

        # suggest settings
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.topsites" = false;

        # clear history on browser close
        "privacy.history.custom" = true;
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown_v2.cache" = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
        "privacy.clearOnShutdown_v2.siteSettings" = false;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
        "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;

        # no onboarding, thanks
        "browser.aboutWelcome.didSeeFinalScreen" = true;

        # Addon recomendations
        "browser.discovery.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;

        # autoenable extensions
        "extensions.autoDisableScopes" = 0;

        # ask where to save files
        "browser.download.useDownloadDir" = false;

        # Crash reports
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;

        # Auto-decline cookies
        "cookiebanners.service.mode" = 2;
        "cookiebanners.service.mode.privateBrowsing" = 2;

        # Tracking
        "browser.contentblocking.category" = "strict";
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;

        # no password manager pls
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;

        # no bookmarks bar
        "browser.toolbars.bookmarks.visibility" = "never";

        # the entire UI customization, lol
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            widget-overflow-fixed-list = [
            ];
            unified-extensions-area = [
            ];
            nav-bar = [
              "sidebar-button"
              "back-button"
              "forward-button"
              "stop-reload-button"
              "vertical-spacer"
              "urlbar-container"
              "save-to-pocket-button"
              "downloads-button"
              "unified-extensions-button"
              "ublock0_raymondhill_net-browser-action"
              "privacy_privacy_com-browser-action"
              "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
            ];
            toolbar-menubar = [
              "menubar-items"
            ];
            TabsToolbar = [
              "tabbrowser-tabs"
              "new-tab-button"
              "alltabs-button"
            ];
            vertical-tabs = [
            ];
            PersonalToolbar = [
            ];
          };
          seen = [
            "privacy_privacy_com-browser-action"
            "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
            "developer-button"
            "ublock0_raymondhill_net-browser-action"
          ];
          dirtyAreaCache = [
            "unified-extensions-area"
            "nav-bar"
            "vertical-tabs"
            "PersonalToolbar"
            "toolbar-menubar"
            "TabsToolbar"
          ];
          currentVersion = 22;
          newElementCount = 3;
        };
      };

      # seemingly does nothing
      search = {
        default = "duckduckgo";
        force = true;
      };
    };
  };
}
