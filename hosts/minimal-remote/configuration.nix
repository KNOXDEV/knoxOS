{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware-configuration.nix
  ];

  # extremely general firmware
  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # use flakes and unfree
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    optimise.automatic = true;
    gc.automatic = true;
  };
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";

  # save space
  boot.tmp.cleanOnBoot = true;
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  networking.hostName = "knoxOS-minimal-remote";
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    publish = { enable = true; domain = true; addresses = true; };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
  ];

  security.sudo.wheelNeedsPassword = true;
  services.openssh = {
    enable = true;
    settings = {
      # only sshkey permitted
      PasswordAuthentication = false;
    };
  };
  users.mutableUsers = false;

  users.users.knox = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
    ];
    initialPassword = "changeme";

    # change this to your public key
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNTdR18zwHnKfBFx+DlC0pLN6CzFLVGnBCVNiKNigcX knox@toaster"
    ];
  };
}
