{
  zen-browser,
  ...
}@args:
let
  potdSettings = builtins.readFile ./programs/picture-of-the-day.ini;
  # The active entry of themes.nix, picked by `vars.theme`.
  theme = args.theme;
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
        (import programs/helix.nix theme.helix)
        (import programs/zellij.nix {
          inherit pkgs;
          zellij-bin = args.zellij-bin;
          theme = theme.zellij;
        })
        ./programs/url-router.nix
      ];

      # Template files
      home.file."${config.xdg.userDirs.templates}/New Text File.txt" = {
        enable = true;
        text = "";
      };
      home.file."${config.xdg.userDirs.templates}/New Markdown File.md" = {
        enable = true;
        text = "";
      };

      home.shell.enableBashIntegration = false;

      # The terminal of choice
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local flavor = ${lib.generators.toLua { } theme.wezterm}

        ''
        + builtins.readFile ./programs/wezterm.lua;
        enableBashIntegration = true;
      };

      # The shell of choice
      # NOTE: LS_COLORS is not set here. programs.vivid below owns it, through
      # its own Nushell integration, so that it follows the active theme.
      programs.nushell = {
        enable = true;
        configFile.source = ./programs/config.nu;
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
        activeTheme = theme.vivid.name;
        inherit (theme.vivid) themes;
        enableBashIntegration = true;
        enableNushellIntegration = true;
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
          theme = theme.tmTheme.name;
        };
        themes = {
          "${theme.tmTheme.name}" = {
            inherit (theme.tmTheme) src file;
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

        # Yazi has no single "use this flavor" key. It keeps one flavor per
        # terminal background and picks between them by what it detects, and an
        # unknown key is dropped in silence rather than flagged, which just
        # leaves the built-in theme in place. Both themes here are light, so
        # both slots name the same flavor and a misdetected background still
        # lands on the right one.
        theme = {
          flavor = {
            light = theme.yazi.name;
            dark = theme.yazi.name;
          };
        }
        // theme.yazi.extraTheme;

        flavors = {
          "${theme.yazi.name}" = theme.yazi.src;
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
          syntax-theme = theme.tmTheme.name;

        };
      };

      # GitUI colors its file and blame views from a .tmTheme it looks up by the
      # name its theme.ron carries, next to theme.ron itself. Without it, it
      # falls back to a built-in and silently stops matching everything else.
      home.file."${config.xdg.configHome}/gitui/${theme.tmTheme.name}.tmTheme" = {
        source = "${theme.tmTheme.src}/${theme.tmTheme.file}";
      };

      programs.gitui = {
        enable = true;
        inherit (theme.gitui) theme;
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
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
          command = "${pkgs.lib.getExe args.switch-monitor-input-source}";
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

      # AI
      programs.antigravity-cli = {
        enable = true;
        package = args.unstablePkgs.antigravity-cli;
        # NOTE: whenever this comes back, it only has colors under Rose Pine --
        # themes.nix leaves `antigravity` null for Flexoki.
        # settings = {
        #   ui = {
        #     theme = theme.antigravity.name;
        #     customThemes = theme.antigravity.customThemes;
        #   };
        #   preferredEditor = "hx";
        #   general.sessionRetention = {
        #     enabled = true;
        #     maxAge = "120d";
        #   };
        #   security = {
        #     auth = {
        #       selectedType = "oauth-personal";
        #     };
        #   };
        # };
      };

      programs.claude-code = {
        enable = true;
        package = args.unstablePkgs.claude-code;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-7z-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-bzip" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-bzip-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-compress" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-cpio" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-gzip" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-lha" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-lzip" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-lzip-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-lzma" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-lzma-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-tarz" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-xar" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-xz" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-xz-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
          "application/zip" = [ "org.gnome.FileRoller.desktop" ];
          "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
          "application/bzip2" = [ "org.gnome.FileRoller.desktop" ];
          "application/vnd.rar" = [ "org.gnome.FileRoller.desktop" ];
          "application/zstd" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-zstd-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        };
      };

      home.stateVersion = args.vars.nixOSVersion;
    };

  home-manager.users.root =
    { ... }:
    {
      imports = [
        (import programs/helix.nix theme.helix)
      ];

      home.stateVersion = args.vars.nixOSVersion;
    };
}
