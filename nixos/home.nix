{
  zen-browser,
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
        (import programs/browsers.nix {
          inherit pkgs config;
          firefox-addons = args.firefox-addons;
          vars = args.vars;
        })
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

      home.file."${config.xdg.configHome}/gitui/rose-pine-dawn.tmTheme" = {
        source = "${args.rosePineTextMateTheme}/dist/rose-pine-dawn.tmTheme";
      };

      programs.gitui = {
        enable = true;
        theme = ./programs/gitui_theme.ron;
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
