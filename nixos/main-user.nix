{
  pkgs,
  unstablePkgs,
  lib,
  ...
}@args:
let
  iconPath = "/var/lib/AccountsService/icons/${args.vars.mainUsername}";
  userConfigPath = "/var/lib/AccountsService/users/${args.vars.mainUsername}";
  iconSource = ./images/profile_picture.jpg; 
in
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

  # 1. Handle the Image File (Atomic, Clean)
  systemd.tmpfiles.rules = [
    "L+ ${iconPath} - - - - ${iconSource}"
  ];

  # 2. Handle the Text Config (Smart Editing)
  system.activationScripts.updateGnomeIcon = lib.stringAfter [ "users" ] ''
    # Ensure the directory exists
    mkdir -p /var/lib/AccountsService/users/

    # Define the config file path
    CFG="${userConfigPath}"
    ICON_LINE="Icon=${iconPath}"

    if [ ! -f "$CFG" ]; then
      # Case A: File doesn't exist. Create it with header and icon.
      echo -e "[User]\n$ICON_LINE" > "$CFG"
      chmod 600 "$CFG"
    else
      # Case B: File exists. We need to surgically update or append.
      
      # Check if an Icon line already exists
      if grep -q "^Icon=" "$CFG"; then
        # Case B1: Icon line exists (wrong or right). Replace it using sed.
        # We use | as delimiter to avoid issues with / in file paths
        ${pkgs.gnused}/bin/sed -i "s|^Icon=.*|$ICON_LINE|" "$CFG"
      else
        # Case B2: File exists, but no Icon line. Append it.
        # Ensure we are under [User] if possible, but appending usually works for GDM.
        echo "$ICON_LINE" >> "$CFG"
      fi
    fi
  '';

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
