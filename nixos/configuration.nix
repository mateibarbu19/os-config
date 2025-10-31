# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  parentArgs,
  nixOSVersion,
  ...
}:
let
  unstablePkgs = import parentArgs.unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix
    ./cachix.nix
    (import ./main-user.nix {
      inherit pkgs unstablePkgs;
      nixOSVersion = nixOSVersion;
      zen-browser = parentArgs.zen-browser;
      firefox-addons = parentArgs.firefox-addons;
    })
  ];

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

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-tour
  ];

  # Install KDE Connect
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  # Esthetic feel on login
  programs.dconf = {
    enable = true;
    profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            "accent-color" = "orange";
          };
        };
      }
    ];
  };
  # INFO: This program has an Open Here extension that I dislike.
  # Also it is non functional at the time of writing.
  programs.nautilus-open-any-terminal.enable = true;

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

  # Everybody gets firefox.
  programs.firefox.enable = true;
  # NOTE: I'm not sure about Thunderbird. But I'm leaving it in for now.
  programs.thunderbird.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # NOTE: Most of these are here for the root user...
  environment.systemPackages = with pkgs; [
    # Nix tools
    nil # language server
    nixd # language server
    nixfmt-rfc-style # formatter
    cachix # community caches

    # TUI work tools for all users
    helix
    bat
    bat-extras.batman
    eza
    tealdeer
    unstablePkgs.yazi
    fzf
    fd

    # Shells
    nushell
    fish
    starship
    # NOTE: This could be don better
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
  ];

  # Enable flatpak
  services = {
    flatpak = {
      enable = true;

      # List the Flatpak applications you want to install
      # Use the official Flatpak application ID (e.g., from flathub.org)
      # Examples:
      packages = [
        "com.github.tchx84.Flatseal" # Manage flatpak permissions - should always have this
        # "com.rtosta.zapzap"              # WhatsApp client
        "io.github.flattool.Warehouse" # Manage flatpaks, clean data, remove flatpaks and deps
        # "it.mijorus.gearlever"           # Manage and support AppImages
        # "io.github.dvlv.boxbuddyrs"      # Manage distroboxes
        # "de.schmidhuberj.tubefeeder"     # watch YT videos
        "de.swsnr.pictureoftheday" # Change my wallpaper based on online sources
      ];

      # Optional: Automatically update Flatpaks when you run nixos-rebuild switch
      update.onActivation = true;
    };
  };

  home-manager.backupFileExtension = "bkp";

  # Set default editor
  # environment.variables.EDITOR = "hx";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

  # NixOS version
  system.stateVersion = nixOSVersion;
}
