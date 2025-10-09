# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {
    config.allowUnfree = true;
  };
  # nix-software-center = import (pkgs.fetchFromGitHub {
  #   owner = "snowfallorg";
  #   repo = "nix-software-center";
  #   rev = "0.1.2";
  #   sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  # }) {};
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./cachix.nix
    ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable important experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define your hostname.
  networking.hostName = "nixos";
  # Enable wireless support via wpa_supplicant.
  # networking.wireless.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "ro";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  # Enable flatpak
  services.flatpak.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matei = {
    # uid = 1000;
    isNormalUser = true;
    description = "Matei Barbu";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      wezterm

      # Version control packages
      git
      unstable.gitui
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
      python313
      python313Packages.python-lsp-server
      python313Packages.python-lsp-ruff
      ruff
      # python313Packages.jedi-language-server


      llvmPackages_latest.clang
      llvmPackages_latest.clang-tools
      bear
      compiledb
      gnumake
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  # Install Thunderbird.
  programs.thunderbird.enable = true;
  # Install KDE Connect
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Nix tools
    home-manager
    nil # language server
    cachix # community caches

    # TUI work tools for all users
    helix
    bat
    bat-extras.batman
    eza
    tealdeer
    unstable.yazi
    fzf
    fd

    # Shells
    nushell
    fish
    starship
    vivid

    # Desktop tools for all users
    gdm-settings
    gnome-tweaks
    gnomeExtensions.system-monitor
    gnomeExtensions.status-icons

    # System tools for all users
    du-dust
    lshw
    pciutils
    usbutils
    ddcutil

    # Virtualisation
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
    distrobox

    # Online tools
    ungoogled-chromium
  ];

  # Set default editor
  environment.variables.EDITOR = "hx";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Monitor testing
  boot.kernelModules = [ "i2c-dev" ];

  # Disable wakeup from sleep from USB interrupt
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE:="0666"
    KERNEL=="i2c-[0-9]*", GROUP:="users"
    # ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x9d2f", ATTR{power/wakeup}="disabled"
  '';


  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # fonts.fontconfig.antialias = false;
  # fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "light";

  programs.dconf.profiles.gdm.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        "accent-color" = "orange";
      };
    };
  }];

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "wezterm";
  };

  systemd.services.copyGdmMonitorsXml = {
    description = "Copy monitors.xml to GDM config";
    after = [ "network.target" "systemd-user-sessions.service" "display-manager.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo \"Running copyGdmMonitorsXml service\" && mkdir -p /run/gdm/.config && echo \"Created /run/gdm/.config directory\" && [ \"/home/matei/.config/monitors.xml\" -ef \"/run/gdm/.config/monitors.xml\" ] || cp /home/matei/.config/monitors.xml /run/gdm/.config/monitors.xml && echo \"Copied monitors.xml to /run/gdm/.config/monitors.xml\" && chown gdm:gdm /run/gdm/.config/monitors.xml && echo \"Changed ownership of monitors.xml to gdm\"'";
      Type = "oneshot";
    };

    wantedBy = [ "multi-user.target" ];
  };

  # NixOS version
  system.stateVersion = "25.05";

  # Copy /etc/nixos/configuration.nix to /run/current-system/configuration.nix
  system.copySystemConfiguration = true;
}
