{
  pkgs,
  unstablePkgs,
  zen-browser,
  firefox-addons,
  ...
}@args:
let
  rosePineFlavors = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "yazi";
    rev = "7fe22e1d7f909bc9d0961edbd52deb745e5b0cfc";
    sha256 = "sha256-zCLGlAX6JOmwcgnNLerSmvhCpYm/PL6JsXBU7Gq2kTI=";
  };
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matei = {
    # uid = 1000;
    isNormalUser = true;
    description = "Matei Barbu";
    initialPassword = "12345678";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    packages = with pkgs; [
      # Always useful
      man-pages

      # Command line tools
      ripgrep
      fd

      # Version control packages
      git
      unstablePkgs.gitui
      delta # also colorful diff

      # A visual software center for NixOS
      # nix-software-center

      gnome-solanum
      gnome-pomodoro
      gcolor3
      gnomeExtensions.brightness-control-using-ddcutil

      easyeffects

      ffmpeg

      # Disk Usage Analyzer
      baobab
      # Tasks and To-Dos with Nextcloud sync
      planify
      # Internet Radio
      shortwave

      # Instant Messaging
      signal-desktop

      # PDF processing
      pdftk

      # Office Tools
      libreoffice-fresh

      # Video Editing
      kdePackages.kdenlive

      # Programming
      # python313
      # python313Packages.python-lsp-server
      # python313Packages.python-lsp-ruff
      # ruff
      # python313Packages.jedi-language-server

      # llvmPackages_latest.clang
      # llvmPackages_latest.clang-tools
      # bear
      # compiledb
      # gnumake
      # gdb

      # Online tools
      ungoogled-chromium
    ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.matei =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        zen-browser.homeModules.beta
        programs/helix.nix
      ];

      programs.gnome-shell = {
        enable = true;
      };

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
          DisableAccounts = true;
          DisableTelemetry = true;

          SanitizeOnShutdown = {
            # Cache = true;
            Cookies = true;
            # History = true;
            # FormData = true;
            # Sessions = true;
            # SiteSettings = true;
          };

          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;

          EnableTrackingProtection = {
            Value = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          SearchEngines = {
            Default = "DuckDuckGo";
          };
        };

        profiles."default" = {
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
                        value = "${args.nixOSVersion}";
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
                        value = "${args.nixOSVersion}";
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
                        value = "release-${args.nixOSVersion}";
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
              containers = config.programs.zen-browser.profiles."default".containers;
            in
            {
              "Space" = {
                id = "c6de089c-410d-4206-961d-ab11f988d40a";
                position = 1000;
              };
              "Personal" = {
                id = "b2c6a9df-40fa-486e-b91a-0cddcf3ef1ae";
                icon = "🫆";
                position = 2000;
              };
              "Study" = {
                id = "cdd10fab-4fc5-494b-9041-325e5759195b";
                icon = "👓";
                container = containers."Study".id;
                position = 3000;
              };
              "Fun" = {
                id = "f39b5c10-71a6-4b09-94d2-bd02dff87b9e";
                icon = "🎠";
                container = containers."Fun".id;
                position = 4000;
              };
              "Shopping" = {
                id = "78aabdad-8aae-4fe0-8ff0-2a0c6c4ccc24";
                icon = "🛒";
                container = containers."Shopping".id;
                position = 5000;
              };
              "Music" = {
                id = "e1d0f2b4-39f8-4c11-a71d-5efc9b32b25c";
                icon = "🎼";
                container = containers."Music".id;
                position = 6000;
              };
            };

          extensions = {
            force = true; # Whether to override all previous firefox settings.

            packages = with firefox-addons.packages.${pkgs.system}; [
              ublock-origin
              decentraleyes
              clearurls
              terms-of-service-didnt-read
              unpaywall
              videospeed
              auth-helper
            ];
          };

          settings = {
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

      programs.wezterm = {
        enable = true;
        extraConfig = builtins.readFile ./programs/wezterm.lua;
      };

      programs.nushell = {
        enable = true;
        configFile.source = ./programs/config.nu;
        environmentVariables = {
          LS_COLORS = lib.hm.nushell.mkNushellInline ''vivid generate rose-pine-dawn'';
        };
      };

      programs.starship = {
        enable = true;
        enableNushellIntegration = true;
      };

      programs.yazi = {
        enable = true;
        enableNushellIntegration = true;

        theme = {
          flavor = {
            use = "rose-pine-dawn";
          };

          icon = (builtins.fromTOML (builtins.readFile "${rosePineFlavors}/themes/rose-pine-dawn.toml")).icon;
        };
        flavors = {
          rose-pine-dawn = "${rosePineFlavors}/flavors/rose-pine-dawn.yazi";
        };
      };

      # Fetch the Delta themes.gitconfig from GitHub
      home.file."${config.xdg.dataHome}/bin/switch_monitor_input_source.sh" = {
        source = ./programs/switch_monitor_input_source.sh;
        executable = true;
      };
      programs.git = {
        enable = true;
        userName = "Matei Barbu";
        userEmail = "mateibarbu19@disroot.org";

        includes = [
          { path = "${config.xdg.configHome}/delta/themes.gitconfig"; }
        ];

        extraConfig = {
          core = {
            editor = "hx";
          };
          push = {
            autoSetupRemote = true;
          };
        };

        delta = {
          enable = true;
          options = {
            navigate = true;
            line-numbers = true;
            side-by-side = true;
            features = "hoopoe";
            syntax-theme = "rose-pine-dawn";

          };
        };
      };

      programs.bat = {
        enable = true;

        config = {
          theme = "rose-pine-dawn";
        };
        themes = {
          rose-pine-dawn = {
            src = pkgs.fetchFromGitHub {
              owner = "rose-pine";
              repo = "tm-theme"; # Bat uses sublime syntax for its themes
              rev = "c4cab0c431f55a3c4f9897407b7bdad363bbb862";
              sha256 = "maQp4QTJOlK24eid7mUsoS7kc8P0gerKcbvNaxO8Mic=";
            };
            file = "dist/themes/rose-pine-dawn.tmTheme";
          };
        };
      };

      home.file."${config.xdg.configHome}/delta/themes.gitconfig" = {
        source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/dandavison/delta/0.18.2/themes.gitconfig";
          sha256 = "sha256-7G/Dz7LPmY+DUO/YTWJ7hOWp/e6fx+08x22AeZxnx5U=";
        };
      };


      dconf.settings = {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Set Dell P2419HC Input Source to DisplayPort";
          command = "${config.xdg.dataHome}/bin/switch_monitor_input_source.sh";
          binding = "<Shift><Control><Alt>d";
          enable-in-lockscreen = true;
        };
      };

      programs.zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      home.stateVersion = args.nixOSVersion;
    };

  home-manager.users.root =
    { lib, ... }:
    {
      imports = [
        programs/helix.nix
      ];

      programs.helix.settings.theme = lib.mkOverride 0 "rose_pine_dawn";

      home.stateVersion = args.nixOSVersion;
    };

  systemd.services.copyGdmMonitorsXml = {
    description = "Copy Matei's monitors.xml to GDM config";
    after = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "copy-gdm-monitors" ''
        set -euo pipefail
        src="/home/matei/.config/monitors.xml"
        dest="/run/gdm/.config/monitors.xml"

        echo "Copying $src to $dest..."
        install -D -m 644 "$src" "$dest"
        chown gdm:gdm "$dest"
        echo "Done."
      '';
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
