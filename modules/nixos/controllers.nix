{pkgs, ...}: {
  # device emulation support (required for Steam input)
  # Note that you will still need to add users to the "uinput" group
  hardware.uinput.enable = true;

  # out-of-the-box support for user-access to various game controllers
  services.udev.packages = [
    pkgs.game-devices-udev-rules
  ];
}
