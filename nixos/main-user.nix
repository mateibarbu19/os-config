{
  pkgs,
  unstablePkgs,
  ...
}@args:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${args.vars.mainUsername} = {
    uid = 1000;
    isNormalUser = true;
    description = args.vars.fullName;
    initialPassword = "12345678";

    shell = pkgs.nushell;

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
      vscodium
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
