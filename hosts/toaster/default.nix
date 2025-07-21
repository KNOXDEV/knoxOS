{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./logiops.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # increase font size
  boot.loader.systemd-boot.consoleMode = "auto";
  # loading screen while booting
  boot.plymouth.enable = true;

  networking.hostName = "toaster";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # flashing zsa keyboards requires special udev rules
  # https://wiki.nixos.org/wiki/ZSA_Keyboards
  hardware.keyboard.zsa.enable = true;

  # nvidia graphics, lets go
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    open = true;

    # Enable the Nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # stable, beta, etc
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # prime
    prime = {
      # manually spec'd to my laptop
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      # offloading means the nvidia driver will only be used when called upon.
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };

    # both are needed for prime
    videoDrivers = [
      "modesetting"
      "nvidia"
    ];
  };

  # I love CUPS!!!!
  # https://wiki.nixos.org/wiki/Printing
  services.printing.enable = true;
  # driverless printing / autodiscovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # use a custom userspace scheduler.
  # may provide improved responsiveness with interactive workloads.
  # requires Kernel 6.12 or later
  # NOTE: I've disabled this after determining its kind of a meme and causes stability issues
  # services.scx = {
  #   enable = true;
  #   scheduler = "scx_bpfland";
  # };

  # device emulation support (required for Steam input)
  # Note that you will still need to add users to the "uinput" group
  hardware.uinput.enable = true;

  # some software is better off flatpak'd
  services.flatpak.enable = true;

  # standard programs
  programs = {
    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        DisablePocket = true;
        OverrideFirstRunPage = "";

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
        };
      };
    };
    git = {
      enable = true;
      config.init.defaultBranch = "main";
    };
    vim = {
      enable = true;
      defaultEditor = true;
    };
    fish.enable = true;

    # we'll be using nix-index to replace this functionality
    command-not-found.enable = false;
  };

  # fonts
  # https://wiki.nixos.org/wiki/Fonts
  fonts = {
    packages = with pkgs; [
      # noto to support as many glyphs as possible
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # nerd fonts
      nerd-fonts.jetbrains-mono
      roboto
      cantarell-fonts

      # chinese, japanese, and korean typefaces
      arphic-ukai
      arphic-uming
      ipafont
      unfonts-core
    ];
  };

  # docker
  virtualisation.docker = {
    enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment = {
    # gnome packages to not install
    gnome.excludePackages = with pkgs; [
      # wastes of space
      gnome-tour
      gnome-user-docs
      gnome-maps
      gnome-font-viewer
      gnome-logs
      gnome-connections
      yelp # help
      seahorse # passwords and keys

      # unncessary
      gnome-shell-extensions
      gnome-software
      xterm

      # basic apps replaced with alternatives
      gnome-text-editor
      gnome-music
      decibels # audio player
      snapshot # webcam viewer
      totem # video player
      geary # email client
      epiphany # firefox fork
      gnome-calendar
      gnome-console
    ];

    # system packages to install globally
    systemPackages = with pkgs; [
      # media player replacements
      celluloid
      amberol

      # essential cli tools
      jq

      # nix dev nice-to-haves
      nil
      alejandra

      # shell nice-to-haves
      ffmpegthumbnailer
      gnomeExtensions.hide-top-bar
      gnomeExtensions.blur-my-shell
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnome-tweaks
      gnome-extension-manager
      adw-gtk3

      # misc cli utils
      ffmpeg
      uutils-coreutils-noprefix
      desktop-file-utils
      pciutils
      usbutils
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.knox = {
    isNormalUser = true;
    description = "Nick Knox";
    extraGroups = ["networkmanager" "wheel" "docker" "uinput" ];
    shell = pkgs.fish;
  };

  # nix settings
  nix = {
    settings.auto-optimise-store = true;
    settings.experimental-features = ["nix-command" "flakes"];
    channel.enable = false;

    # auto garbage collect
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # out-of-the-box support for user-access to various game controllers
  services.udev.packages = [
    pkgs.game-devices-udev-rules
  ];

  # firewall
  # networking.firewall.enable = false;

  # Basically used to pin application data storage formats
  # to the original version of NixOS installed on this machine.
  system.stateVersion = "25.05";
}
