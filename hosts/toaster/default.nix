{
  pkgs,
  overlays,
  nixosModules,
  homeManagerModules,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    nixosModules.hardware.precision5570
    nixosModules.logiops
  ];

  nixpkgs = {
     # Allow unfree packages
    config.allowUnfree = true;

    # overlay our custom and imported packages
    overlays = [
      overlays.additions
      overlays.vscode-extensions
      overlays.firefox-addons
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # increase font size
  boot.loader.systemd-boot.consoleMode = "auto";
  # loading screen while booting
  boot.plymouth.enable = true;

  # networking
  networking.hostName = "toaster";
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

  # device emulation support (required for Steam input)
  # Note that you will still need to add users to the "uinput" group
  hardware.uinput.enable = true;

  # out-of-the-box support for user-access to various game controllers
  services.udev.packages = [
    pkgs.game-devices-udev-rules
  ];

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
  virtualisation.docker.enable = true;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.knox = {
    isNormalUser = true;
    description = "Nick Knox";
    extraGroups = ["networkmanager" "wheel" "docker" "uinput" ];
    shell = pkgs.fish;
  };

  # home manager configuration for the only user above
  home-manager = {
    # follow nixos nixpkgs
    useGlobalPkgs = true;
    useUserPackages = true;

    users.knox = { pkgs, lib, ... }: {
      home.username = "knox";
      home.homeDirectory = "/home/knox";
      home.stateVersion = "25.05"; # DO NOT CHANGE EVER

      # home-manager modules
      imports = [
        homeManagerModules.firefox
        homeManagerModules.vscode
        homeManagerModules.gnome-settings
      ];

      # sets the wallpaper to be used in the gnome-settings module
      gnome-settings.wallpaper = ./wallpaper.jpg;

      # home-manager programs
      programs = {
        git = {
          enable = true;
          userName = "Nick Knox";
          userEmail = "nick@knox.codes";
        };

        # Enable the fish shell explictly so home manager knows about it.
        # Be a bit careful; this will override certain fish configurations at the NixOS level.
        fish.enable = true;

        # chromium sometimes useful
        chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;
        };

        # boy howdy do I love electron
        vesktop.enable = true;

        # TODO: will be available starting with next stable
        # obsidian.enable = true;

        # obs with nvidia support
        obs-studio = {
          enable = true;
          package = pkgs.obs-studio.override {
            cudaSupport = true;
          };
        };

        # hipster cli tools
        zoxide = {
          enable = true;
          enableFishIntegration = true;
          options = ["--cmd cd"];
        };
        bat.enable = true;
        eza = {
          enable = true;
          enableFishIntegration = true;
        };
        fastfetch.enable = true;
        fd.enable = true;
        ripgrep.enable = true;
      };

      # The home.packages option allows you to install Nix packages into your
      # environment.
      home.packages = with pkgs; [
        # sorry, i like GUIs
        kdePackages.kdenlive
        fragments
        signal-desktop
        dconf-editor
        obsidian
        spotify
        calibre

        # required for the shell aliases below
        yt-dlp

        # custom packages
        dv
        fftrim
      ];

      # shell aliases 
      home.shellAliases = {
        # download youtube as either video or audio: highest available quality
        yta = ''yt-dlp -o "~/Downloads/%(title)s.%(ext)s" --restrict-filenames -f ba --remux-video ogg "$1"'';
        ytv = ''yt-dlp -o "~/Downloads/%(title)s.%(ext)s" --restrict-filenames --recode-video mp4 "$1"'';

        # nix shorthands
        upgrade = ''nix flake update && sudo nixos-rebuild switch --flake path://'';
      };

      # restarting modified systemd units after a home-manager switch is nice
      systemd.user.startServices = "sd-switch";

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
  };

  # Basically used to pin application data storage formats
  # to the original version of NixOS installed on this machine.
  # Changing this will probably result in lost data. 
  system.stateVersion = "25.05";
}
