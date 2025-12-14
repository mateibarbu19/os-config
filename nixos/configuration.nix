# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  vars,
  parentArgs,
  source,
  ...
}@args:
let
  unstablePkgs = import parentArgs.unstable {
    system = pkgs.stdenv.hostPlatform.system; # TODO: what should I do with system?
    config.allowUnfree = true;
  };
in
{
  # This copies the flake source into the Nix store and
  # creates a symlink at /etc/nixos-flake pointing to it.
  environment.etc."nixos-flake".source = source;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./cachix.nix
    (import ./hardware-configuration.nix (
      let
        modulesPath = args.modulesPath;
      in
      {
        inherit
          config
          lib
          modulesPath
          vars
          ;
      }
    ))
    (import ./main-user.nix {
      inherit
        pkgs
        unstablePkgs
        lib
        vars
        ;
    })
    (import ./home.nix (
      let
        zen-browser = parentArgs.zen-browser;
        firefox-addons = parentArgs.firefox-addons;
        rosePineFlavors = parentArgs.rosePineFlavors;
        rosePineTextMateTheme = parentArgs.rosePineTextMateTheme;
        deltaThemes = parentArgs.deltaThemes;
      in
      {
        inherit
          vars
          zen-browser
          firefox-addons
          rosePineFlavors
          rosePineTextMateTheme
          deltaThemes
          ;
      }
    ))
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define your hostname.
  networking.hostName = args.vars.hostName;
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
  services = {
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
            "accent-color" = args.vars.gnomeAccentColor;
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

    # Shell environment
    bash
    nushell
    fish
    starship
    # NOTE: This could be don better
    vivid
    zoxide

    # TUI work tools for all users
    helix
    bat
    bat-extras.batman
    eza
    tealdeer
    unstablePkgs.yazi
    fzf
    fd

    # Desktop tools for all users
    gdm-settings
    gnome-tweaks
    gnomeExtensions.system-monitor
    gnomeExtensions.status-icons

    # System tools for all users
    dust
    lshw
    pciutils
    usbutils
    ddcutil
    wget
    zip
    unzip

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

      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };

      # List the Flatpak applications you want to install
      # Use the official Flatpak application ID (e.g., from flathub.org)
      # Examples:
      packages = [
        # "com.github.tchx84.Flatseal" # Manage flatpak permissions - should always have this
        # "com.rtosta.zapzap"              # WhatsApp client
        # "io.github.flattool.Warehouse" # Manage flatpaks, clean data, remove flatpaks and deps
        # "it.mijorus.gearlever"           # Manage and support AppImages
        # "io.github.dvlv.boxbuddyrs"      # Manage distroboxes
        # "de.schmidhuberj.tubefeeder"     # watch YT videos
        "flathub:app/de.swsnr.pictureoftheday/x86_64/stable" # Change my wallpaper based on online sources
      ];

      # Optional: Automatically update Flatpaks when you run nixos-rebuild switch
      # update.onActivation = true;

      overrides = {
        "de.swsnr.pictureoftheday"."System Bus Policy" = {
          "org.freedesktop.login1" = [ "talk" ];
        };
      };
    };
  };

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
  virtualisation = {
    containers.enable = true;

    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # NixOS version
  system.stateVersion = args.vars.nixOSVersion;
}
