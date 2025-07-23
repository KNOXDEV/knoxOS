{
  logiops = import ./logiops.nix;
  hardware = {
    precision5570 = import ./hardware/dell-precision-5570.nix;
  };
}