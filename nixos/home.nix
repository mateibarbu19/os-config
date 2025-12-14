{
  pkgs,
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
  rosePineTextMateTheme = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "tm-theme"; # Bat uses sublime syntax for its themes
    rev = "c4cab0c431f55a3c4f9897407b7bdad363bbb862";
    sha256 = "maQp4QTJOlK24eid7mUsoS7kc8P0gerKcbvNaxO8Mic=";
  };
  deltaThemes = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dandavison/delta/0.18.2/themes.gitconfig";
    sha256 = "sha256-7G/Dz7LPmY+DUO/YTWJ7hOWp/e6fx+08x22AeZxnx5U=";
  };
in
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bkp";
  };

  home-manager.users.${args.vars.mainUsername} =
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

      home.shell.enableBashIntegration = false;

      # The terminal of choice
      programs.wezterm = {
        enable = true;
        extraConfig = builtins.readFile ./programs/wezterm.lua;
        enableBashIntegration = true;
      };

      # The shell of choice
      programs.nushell = {
        enable = true;
        configFile.source = ./programs/config.nu;
        environmentVariables = {
          LS_COLORS = lib.hm.nushell.mkNushellInline ''vivid generate rose-pine-dawn'';
        };
      };

      # Keeping things consistent with the base shell
      programs.bash = {
        enable = true;
        initExtra = ''
          if [[ -n $WEZTERM_EXECUTABLE ]]; then
            export LS_COLORS="$(vivid generate rose-pine-dawn)";
          fi
        '';
      };

      programs.mcfly = {
        enable = true;
        enableBashIntegration = true;
      };

      # TODO: Disable comments when a new version is released
      # programs.vivid = {
      #   enable = true;
      #   activeTheme = "rose-pine-dawn";
      #   enableBashIntegration = true;
      # };

      programs.starship = {
        enable = true;
        enableNushellIntegration = true;
        enableBashIntegration = true;

        settings = {
          shell = {
            disabled = false;
            bash_indicator = " ";
            nu_indicator = "";
            format = "[$indicator]($style)";
          };
          time = {
            disabled = false;
            format = " [$time]($style) ";
          };
          nix_shell.heuristic = true;
        };

      };

      programs.bat = {
        enable = true;

        config = {
          theme = "rose-pine-dawn";
        };
        themes = {
          rose-pine-dawn = {
            src = rosePineTextMateTheme;
            file = "dist/themes/rose-pine-dawn.tmTheme";
          };
        };
      };

      programs.zoxide = {
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
      home.file."${config.xdg.configHome}/delta/themes.gitconfig" = {
        source = deltaThemes;
      };

      programs.git = {
        enable = true;
        userName = args.vars.fullName;
        userEmail = args.vars.userEmail;

        includes = [
          { path = "${config.xdg.configHome}/delta/themes.gitconfig"; }
        ];

        extraConfig = {
          core.editor = "hx";
          pull.rebase = true;
          push.autoSetupRemote = true;
          init.defaultBranch = "main";
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

      programs.ssh = {
        enable = true;
        matchBlocks = {
          "fep" = {
            user = args.vars.fepUser;
            hostname = "fep.grid.pub.ro";
            forwardX11 = true;
            forwardX11Trusted = true;
            serverAliveInterval = 60;
          };
          "10.*" = {
            user = "student";
            identityFile = "~/.ssh/id_openstack";
            forwardX11 = true;
            forwardX11Trusted = true;
            proxyJump = "fep";
          };
        };
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
                        value = "${args.vars.nixOSVersion}";
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
                        value = "${args.vars.nixOSVersion}";
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
                        value = "release-${args.vars.nixOSVersion}";
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
              "Default (Normal)" = {
                id = "c6de089c-410d-4206-961d-ab11f988d40a";
                icon = "🏠";
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

      home.file."${config.xdg.dataHome}/bin/switch_monitor_input_source.sh" = {
        source = ./programs/switch_monitor_input_source.sh;
        executable = true;
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
        "org/gnome/desktop/interface" = {
          "accent-color" = args.vars.gnomeAccentColor;
          "locate-pointer" = true;
          "clock-show-seconds" = true;
        };
        "org/gnome/desktop/mutter" = {
          "locate-pointer-key" = "Control_R";
        };
      };

      home.file.".var/app/de.swsnr.pictureoftheday/config/glib-2.0/settings/keyfile" = {
        source = ./programs/picture-of-the-day.ini;
      };

      home.stateVersion = args.vars.nixOSVersion;
    };

  home-manager.users.root =
    { lib, ... }:
    {
      imports = [
        programs/helix.nix
      ];

      programs.helix.settings.theme = lib.mkOverride 0 "rose_pine_dawn";

      home.stateVersion = args.vars.nixOSVersion;
    };
}
