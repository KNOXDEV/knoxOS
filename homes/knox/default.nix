{
  pkgs,
  lib,
  overlays,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "knox";
  home.homeDirectory = "/home/knox";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  nixpkgs = {
    config.allowUnfree = true;

    # overlay over nixpkgs so we can access things like vscode extensions and custom packages
    overlays = with overlays; [
      vscode-extensions
      firefox-addons
      additions
      modifications
    ];
  };

  # imported home-manager modules
  imports = [
    ./firefox.nix
  ];

  # home-manager programs
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscodium;

      mutableExtensionsDir = false;

      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.open-vsx; [
          jnoortheen.nix-ide
        ];
        userSettings = {
          "nix.enableLanguageServer" = true;
          "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
          "nix.serverPath" = "${pkgs.nil}/bin/nil";
          "nix.serverSettings"."nil"."formatting"."command" = ["${pkgs.alejandra}/bin/alejandra"];
        };
      };
    };
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

    # required for the shell aliases below
    yt-dlp

    # custom packages
    dv
    fftrim
  ];

  # shell aliases 
  # TODO: does not appear to be working yet?
  home.shellAliases = {
    # download youtube as either video or audio: highest available quality
    yta = ''yt-dlp -o "~/Downloads/%(title)s.%(ext)s" --restrict-filenames -f ba --remux-video ogg "$1"'';
    ytv = ''yt-dlp -o "~/Downloads/%(title)s.%(ext)s" --restrict-filenames --recode-video mp4 "$1"'';
  };

  # gnome settings
  dconf = {
    enable = true;
    settings = {
      # enable extensions
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          hide-top-bar.extensionUuid
          dash-to-dock.extensionUuid
          appindicator.extensionUuid
        ];
        last-selected-power-profile = "performance";
        # dock order
        favorite-apps = ["firefox.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Console.desktop"];
        # i would love to set the app-picker-layout automatically as well but
        # dconf2nix chokes on this for some reason and I don't feel like writing it by hand.
        # app-picker-layout = [];
      };
      # extension settings
      "org/gnome/shell/extensions/dash-to-dock" = {
        show-trash = false;
        dash-max-icon-size = 64;
      };
      "org/gnome/shell/extensions/hidetopbar".enable-active-window = false;

      # tweaks
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        font-hinting = "full";
        font-antialiasing = "rgba";
        gtk-theme = "adw-gtk3-dark";
        show-battery-percentage = true;
      };

      "org/gnome/desktop/background" = let
        wallpaper = ./wallpaper.jpg;
      in {
        color-shading-type = "solid";
        picture-options = "fill";
        picture-uri = "file://${wallpaper}";
        picture-uri-dark = "file://${wallpaper}";
      };

      # screen diming / poweroff while plugged in
      "org/gnome/settings-daemon/plugins/power".idle-dim = false;
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
      "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 300;

      # no indexing, thanks
      "org/freedesktop/tracker/miner/files".index-recursive-directories = [];

      # mouse acceleration
      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
        speed = 0.6;
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # ".screenrc".source = dotfiles/screenrc;

    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # restarting modified systemd units after a home-manager switch is nice
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
