{
  pkgs,
  overlays,
  nixosModules,
  lib,
  ...
}: {
  imports = with nixosModules; [
    ./hardware-configuration.nix
    # locally defined
    hardware.precision5570
    logiops
    controllers

    # community modules
    nix-index
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

  # provide a bootable specialization to use power saving instead
  specialisation = {
    powersave.configuration = {
      hardware.nvidia.prime = {
        # disable sync, enable offloading
        sync.enable = lib.mkForce false;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
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

  # Allow the desktop user to set the timezone
  time.timeZone = lib.mkForce null;

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

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.gnome.core-apps.enable = false;
  services.gnome.sushi.enable = true;

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

  # i have a qmk programmable keyboard
  hardware.keyboard.qmk.enable = true;

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

    # chromium sometimes useful, although note that this doesn't actually install it,
    # so pick a package in environment.systemPackages
    chromium = {
      enable = true;
      # ublock origin
      extensions = ["cjpalhdlnbpafiamejdnhcphjbkeiagm"];
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
      };
    };

    # vscodium with extensions
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.open-vsx; [
        # general nix trappings
        jnoortheen.nix-ide
        mkhl.direnv

        # useful language-specific plugins
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
      ];
    };
    # obsidian = {};

    gnome-disks.enable = true;

    # obs with nvenc support
    obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {
        cudaSupport = true;
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

    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    # requires virtualization.libvirtd to be enabled
    virt-manager.enable = true;

    # hipster cli tools
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      flags = ["--cmd cd"];
    };
    bat.enable = true;
  };

  # fonts
  # https://wiki.nixos.org/wiki/Fonts
  fonts = {
    packages = with pkgs; [
      # noto to support as many glyphs as possible
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

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

  # libvirt for virt-manager
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment = {
    # todo: find a better place for these
    shellAliases = {
      # download youtube as either video or audio: highest available quality
      yta = ''yt-dlp -o "~/Downloads/%(title)s.%(ext)s" --restrict-filenames -f ba --remux-video ogg "$1"'';
      ytv = ''yt-dlp -o "~/Downloads/%(title)s.%(ext)s" --restrict-filenames --recode-video mp4 "$1"'';

      # nix shorthands
      upgrade = ''nix flake update && sudo nixos-rebuild switch --flake path:// && sudo systemctl shutdown --now'';
    };

    sessionVariables = {
      # reeee: https://github.com/NixOS/nixpkgs/issues/378139
      NAUTILUS_4_EXTENSION_DIR = "${pkgs.nautilus-python}/lib/nautilus/extensions-4";
    };

    # system packages to install globally
    systemPackages = with pkgs; [
      # media player replacements
      celluloid
      amberol
      fragments
      calibre
      kdePackages.kdenlive
      audacity

      # misc cli utils
      ffmpeg
      helix
      uutils-coreutils-noprefix
      desktop-file-utils
      pciutils
      usbutils
      file
      patchelf
      jq
      fd
      eza
      fastfetch
      ripgrep
      yt-dlp
      # custom packages
      dv
      fftrim

      # nix dev nice-to-haves
      nil
      alejandra

      # shell nice-to-haves
      ffmpegthumbnailer
      gnomeExtensions.hide-top-bar
      gnomeExtensions.blur-my-shell
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnome-clocks
      gnome-tweaks
      gnome-extension-manager
      gnome-system-monitor
      papers # document viewer
      loupe # image viewer
      nautilus # file browser
      ghostty # terminal
      adw-gtk3
      dconf-editor

      # i love browsers!!!
      firefox
      ungoogled-chromium
      obsidian
      spotify
      signal-desktop
      vesktop

      # for programming my keyboard
      qmk
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
    extraGroups = ["networkmanager" "wheel" "docker" "uinput"];
    shell = pkgs.fish;
  };

  # Basically used to pin application data storage formats
  # to the original version of NixOS installed on this machine.
  # Changing this will probably result in lost data.
  system.stateVersion = "25.05";
}
