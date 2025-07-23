{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    gnome-settings.wallpaper = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = {
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

        # set wallpaper according to config
        "org/gnome/desktop/background" = lib.mkIf (builtins.hasAttr "wallpaper" config.gnome-settings) {
          color-shading-type = "solid";
          picture-options = "fill";
          picture-uri = "file://${config.gnome-settings.wallpaper}";
          picture-uri-dark = "file://${config.gnome-settings.wallpaper}";
        };

        # screen diming / poweroff while plugged in
        "org/gnome/settings-daemon/plugins/power".idle-dim = false;
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
        "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 0;

        # no indexing, thanks
        "org/freedesktop/tracker/miner/files".index-recursive-directories = [];

        # mouse acceleration
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = 0.6;
        };
      };
    };
  };
}
