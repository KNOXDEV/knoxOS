{
  config,
  ...
}: {
  # NixOS module for the Dell Precision 5570

  # mainly enabling nvidia graphics with modesetting.
  hardware.graphics.enable = true;
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

    prime = {
      # manually spec'd to the laptop
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      # sync means the graphics card will always be ready to go, which provides slightly snappier desktop performance.
      sync.enable = true;
      # offloading means the nvidia driver will only be used when called upon.
      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };
    };
  };

  # this laptop supports firmware update
  services.fwupd.enable = true;

  # both are needed for PRIME
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  # variable to avoid an obscure annoying bug on GNOME/Nvidia Optimus setups
  # https://wiki.archlinux.org/title/GTK#GTK4_applications_using_the_dGPU_on_NVIDIA_Optimus_setups
  environment.variables = {
    GSK_RENDERER = "ngl";
  };
}
