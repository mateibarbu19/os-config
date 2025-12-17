{
  zen-browser,
  firefox-addons,
  ...
}@args:
let
  potdSettings = builtins.readFile ./programs/picture-of-the-day.ini;
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
      };

      programs.mcfly = {
        enable = true;
        enableBashIntegration = true;
      };

      programs.vivid = {
        enable = true;
        activeTheme = "rose-pine-dawn";
        enableBashIntegration = true;
      };

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
            src = args.rosePineTextMateTheme;
            file = "dist/rose-pine-dawn.tmTheme";
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

          icon =
            (builtins.fromTOML (builtins.readFile "${args.rosePineFlavors}/themes/rose-pine-dawn.toml")).icon;
        };
        flavors = {
          rose-pine-dawn = "${args.rosePineFlavors}/flavors/rose-pine-dawn.yazi";
        };
      };

      programs.git = {
        enable = true;

        includes = [
          { path = args.deltaThemes; }
        ];

        settings = {
          user.name = args.vars.fullName;
          user.email = args.vars.userEmail;

          core.editor = "hx";
          pull.rebase = true;
          push.autoSetupRemote = true;
          init.defaultBranch = "main";
        };

      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;

        options = {
          navigate = true;
          line-numbers = true;
          side-by-side = true;
          features = "hoopoe";
          syntax-theme = "rose-pine-dawn";

        };
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

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

            packages = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
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
          accent-color = args.vars.gnomeAccentColor;
          locate-pointer = true;
          clock-show-seconds = true;
        };
        "org/gnome/mutter" = {
          locate-pointer-key = "Control_R";
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-automatic = true;
        };
        "org/gnome/shell" = {
          favorite-apps = [
            "zen-beta.desktop"
            "org.wezfurlong.wezterm.desktop"
            "org.gnome.Nautilus.desktop"
          ];

          disable-user-extensions = false; # Enables extension system
          enabled-extensions = [
            "gsconnect@andyholmes.github.io"
            "system-monitor@gnome-shell-extensions.gcampax.github.com"
            "status-icons@gnome-shell-extensions.gcampax.github.com"
            "pomodoro@arun.codito.in"
            "display-brightness-ddcutil@themightydeity.github.com"
          ];
        };
        "org/gnome/shell/extensions/system-monitor" = {
          show-swap = false;
        };
      };

      home.activation.configurePictureOfTheDay = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.var/app/de.swsnr.pictureoftheday/config/glib-2.0/settings

        # Write the settings file (using cat to ensure it's a regular writable file)
        cat <<EOF > $HOME/.var/app/de.swsnr.pictureoftheday/config/glib-2.0/settings/keyfile
        ${potdSettings}
        EOF
      '';

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
