{...}: let
  amo = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
in {
  programs.librewolf = {
    enable = true;

    # extensions installed declaratively via enterprise policy (no NUR needed)
    policies.ExtensionSettings = {
      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = amo "ublock-origin";
      };
      "addon@darkreader.org" = {
        installation_mode = "force_installed";
        install_url = amo "darkreader";
      };
      # vim-style keys/hints/:commands, the qutebrowser feel
      "tridactyl.vim@cmcaine.co.uk" = {
        installation_mode = "force_installed";
        install_url = amo "tridactyl-vim";
      };
    };

    profiles.default = {
      isDefault = true;

      userChrome = builtins.readFile ./userChrome.css;

      search = {
        force = true;
        default = "ddg";
        engines = {
          sx = {
            name = "SearXNG";
            urls = [{template = "https://searx.be/search?q={searchTerms}";}];
            definedAliases = ["sx"];
          };
          nix = {
            name = "Nix Packages";
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            definedAliases = ["nix"];
          };
          hm = {
            name = "Home Manager Options";
            urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}";}];
            definedAliases = ["hm"];
          };
        };
      };

      # librewolf already ships hardened (RFP, no telemetry, uBO-friendly, ...);
      # these only add the minimal UI + qutebrowser-style "forget everything"
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # minimal ui
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.uidensity" = 1;
        "browser.tabs.tabmanager.enabled" = false;
        "browser.tabs.firefox-view" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.quicksuggest.enabled" = false; # no "Firefox Suggest"
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.shortcuts.quickactions" = false;
        "browser.urlbar.quickactions.enabled" = false;
        "ui.key.menuAccessKeyFocuses" = false;

        # privacy: nothing persists (like private_browsing in qutebrowser)
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
        "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "network.cookie.cookieBehavior" = 5; # total cookie protection
        "network.http.referer.XOriginPolicy" = 1; # same-origin referers
        "media.autoplay.default" = 5; # block all autoplay
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;
        "media.peerconnection.ice.default_address_only" = true;
        "dom.security.https_only_mode" = true;
      };
    };
  };
}
