{enumerateCustomPackages, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: enumerateCustomPackages final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
}