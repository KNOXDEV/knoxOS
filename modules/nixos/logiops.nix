{
  config,
  pkgs,
  ...
}: {
  # A few things of note about this file: 
  # I do not particularly like that I have to include this within the NixOS system configuration.
  # I do not like that I have to specify the name of my mouse explicitly here.
  # I do not like that I have to use bluetooth and cannot use the unifying receiver.
  # TL;DR: When something better than logiops comes along, please switch to that.
  
  # https://github.com/PixlOne/logiops/blob/5547f52cadd2322261b9fbdf445e954b49dfbe21/src/logid/logid.service.in
  systemd.services.logid = {
    description = "Logitech Configuration Daemon";
    startLimitIntervalSec = 0;
    after = ["multi-user.target"];
    wantedBy = ["graphical.target"];
    wants = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      # putting this here is enough to implicitly include logiops,
      # but it won't work unless you also install it globally via system packages.
      ExecStart = "${pkgs.logiops}/bin/logid";
      User = "root";
      Restart = "on-failure";
      RestartSec = 3;
    };
    restartTriggers = [
      config.environment.etc."logid.cfg".source
    ];
  };

  environment.systemPackages = [ pkgs.logiops ];

  # current config for logiops
  # Basically just uses gestures to change workspaces.
  environment.etc."logid.cfg".text = ''
  devices: ({
    name: "MX Master 3S";
    smartshift: { on: true; threshold: 30; };
    dpi: 1000;
    hiresscroll: { hires: true; invert: false; target: false; };

    buttons: ({
      cid: 0xc3;
      action = {
        type: "Gestures";
        gestures: ({
            direction: "Left";
            mode: "OnRelease";
            action = {
              type: "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_PAGEUP"];
            };
          }, {
            direction: "Right";
            mode: "OnRelease";
            action = {
              type: "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_PAGEDOWN"];
            };
          }, {
            direction: "None";
            mode: "OnRelease";
            action = {
              type: "Keypress";
              keys: ["KEY_LEFTMETA"]
            };
          }
        );
      };
    });
  });
  '';
}
