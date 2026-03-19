{
  pkgs,
  config,
  firefox-addons,
  vars,
  ...
}:
{
  programs.zen-browser = {
    enable = true;

    languagePacks = [
      "en-GB"
      "ro"
    ];

    policies = {
      DisableAppUpdate = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableTelemetry = true;

      SanitizeOnShutdown = {
        # Cache = true;
        Cookies = true;
        # History = true;
        # FormData = true;
        # Sessions = true;
        # SiteSettings = true;
      };

      NoDefaultBookmarks = true;

      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      SearchEngines = {
        Default = "DuckDuckGo";
      };

      ExtensionSettings = {
        "*".installation_mode = "allowed"; # allows user to install other extensions

        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };

        "jid1-BoFifL9Vbdl2zQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };

        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };

        "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/terms-of-service-didnt-read/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };

        "{f209234a-76f0-4735-9920-eb62507a54cd}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/unpaywall/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };

        "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/videospeed/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };

        "authenticator@mymindstorm" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/auth-helper/latest.xpi";
          installation_mode = "normal_installed";
          private_browsing = true;
        };
      };

      "3rdparty".Extensions."uBlock0@raymondhill.net" = {
        adminSettings = {
          # Force-enable specific filter lists
          selectedFilterLists = [
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "easyprivacy"
            "urlhaus-1"
            "plowe-0"
            "ROU-1"
          ];

          whitelist = [
            "chrome-extension-scheme"
            "moz-extension-scheme"
            "duckduckgo.com" # let them make some money
          ];
        };
      };
    };

    profiles.default = {
      search = {
        force = true;
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "${vars.nixOSVersion}";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "${vars.nixOSVersion}";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "Home Manager" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "release";
                    value = "release-${vars.nixOSVersion}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
        };
      };

      containersForce = true; # Whether to force replace the existing containers configuration.
      containers = {
        Personal = {
          color = "blue";
          icon = "fingerprint";
          id = 1;
        };
        Study = {
          color = "turquoise";
          icon = "chill";
          id = 2;
        };
        Shopping = {
          color = "purple";
          icon = "cart";
          id = 3;
        };
        Fun = {
          color = "pink";
          icon = "pet";
          id = 4;
        };
        Music = {
          color = "toolbar";
          icon = "fence";
          id = 5;
        };
        "ZOther 1" = {
          color = "yellow";
          icon = "circle";
          id = 10;
        };
        "ZOther 2" = {
          color = "orange";
          icon = "circle";
          id = 11;
        };
        "ZOther 3" = {
          color = "red";
          icon = "circle";
          id = 12;
        };
      };

      spacesForce = true; # Whether to force replace the existing spaces configuration.
      spaces =
        let
          containers = config.programs.zen-browser.profiles.default.containers;
        in
        {
          # NOTE: Number prefix in names is a hack.
          "1. Regular" = {
            id = "c6de089c-410d-4206-961d-ab11f988d40a";
            icon = "🏠";
          };
          "2. Personal" = {
            id = "b2c6a9df-40fa-486e-b91a-0cddcf3ef1ae";
            icon = "🫆";
          };
          "3. Study" = {
            id = "cdd10fab-4fc5-494b-9041-325e5759195b";
            icon = "👓";
            container = containers.Study.id;
          };
          "4. Fun" = {
            id = "f39b5c10-71a6-4b09-94d2-bd02dff87b9e";
            icon = "🎠";
            container = containers.Fun.id;
          };
          "5. Shopping" = {
            id = "78aabdad-8aae-4fe0-8ff0-2a0c6c4ccc24";
            icon = "🛒";
            container = containers.Shopping.id;
          };
          "6. Music" = {
            id = "e1d0f2b4-39f8-4c11-a71d-5efc9b32b25c";
            icon = "🎼";
            container = containers.Music.id;
          };
        };

      # NOTE: Old config
      # extensions = {
      #   force = true; # Whether to override all previous firefox settings.

      #   packages = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
      #     ublock-origin
      #     decentraleyes
      #     clearurls
      #     terms-of-service-didnt-read
      #     unpaywall
      #     videospeed
      #     auth-helper
      #   ];
      # };

      settings =
        let
          serif = "Source Serif 4";
          sans = "Source Sans 3";
          mono = "Source Code Pro";
        in
        {
          "browser.search.suggest.enabled" = true;

          # TODO: This is a hack. It enables all extensions once installed!
          "extensions.autoDisableScopes" = 0;

          "font.language.group" = "x-unicode";
          "font.name.monospace.x-unicode" = mono;
          "font.name.monospace.x-western" = mono;
          "font.name.sans-serif.x-unicode" = sans;
          "font.name.sans-serif.x-western" = sans;
          "font.name.serif.x-unicode" = serif;
          "font.name.serif.x-western" = serif;

          # "zen.tabs.show-newtab-vertical" = false;
          # "zen.theme.accent-color" = "#8aadf4";
          # "zen.urlbar.behavior" = "float";
          # "zen.view.window.scheme" = 0;
          # "zen.view.compact.hide-toolbar" = true;
          "zen.view.compact.enable-at-startup" = true;
          "zen.view.compact.toolbar-flash-popup" = true;
          "zen.view.show-newtab-button-top" = false;
          "zen.welcome-screen.seen" = true;
          "zen.workspaces.continue-where-left-off" = true;

          # Disable some telemetry
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.sessions.current.clean" = true;
          "devtools.onboarding.telemetry.logged" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
        };
    };
  };

  programs.firefox = {
    enable = true;

    nativeMessagingHosts = [ pkgs.firefoxpwa ];
  };

  programs.firefoxpwa = {
    enable = true;
    profiles = {
      "01KM3VBE0VG1Z5B0CK0KSBX0V8" = {
        name = "Test profile";

        sites."01KM3VHKRKMC1NDR8B1PAREBDR" = {
          name = "MDN Web Docs";
          url = "https://developer.mozilla.org/";
          manifestUrl = "https://developer.mozilla.org/manifest.f42880861b394dd4dc9b.json";

          settings = {
            manifest = {
              background_color = "#ffffff";
              theme_color = "#000000";
            };
          };

          desktopEntry = {
            enable = true;

            icon = pkgs.fetchurl {
              url = "https://developer.mozilla.org/favicon-192x192.png";
              sha256 = "0p8zgf2ba48l2pq1gjcffwzmd9kfmj9qc0v7zpwf2qd54fndifxr";
            };
          };
        };
      };

      "01KM3X9Q1H5285KV8CWC9J37AT".sites."01KM3X9Q70R1T08P1XG30SJ6FA" = {
          name = "Teams 2";
          url = "https://teams.microsoft.com/v2/";
          manifestUrl = "https://teams.microsoft.com/v2/manifest.json";

          settings = {
            manifest = {
              background_color = "#ffffff";
              theme_color = "#ebebeb";
            };
          };

          desktopEntry = {
            enable = true;

            icon = pkgs.fetchurl {
              url = "https://statics.teams.cdn.office.net/evergreen-assets/icons/windows/teams-icon-pwa-v2025-192.png";
              sha256 = "sha256-4AFuKBLMZp9duee79MAvrzegooh4vhAuGcQnOfZOj80=";
            };
          };
      };
    };
  };
}
