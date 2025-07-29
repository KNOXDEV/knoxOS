{
  description = "KnoxOS as a Nix flake";

  inputs = {
    # pinned to stable for now
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # this is to provide command-not-found functionality via nix-index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # vs-code extensions as nix packages, generated automatically
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Firefox extensions flake
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-index-database,
    ...
  } @ inputs: let
    systems = ["x86_64-linux"];

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # function that enumerates our custom packages, based on a provided version of nixpkgs
    enumerateCustomPackages = import ./packages;

    # group together all the overlays we've imported
    importedOverlays = {
      vscode-extensions = inputs.nix-vscode-extensions.overlays.default;
      firefox-addons = inputs.firefox-addons.overlays.default;
    };

    # group all the modules we've imported
    importedNixosModules = {
      nix-index = inputs.nix-index-database.nixosModules.nix-index;
    };
  in {
    # custom packages
    packages = forAllSystems (system: enumerateCustomPackages nixpkgs.legacyPackages.${system});

    # custom nixpkgs overlays, mainly for using with our primary configurations
    overlays = import ./overlays {inherit enumerateCustomPackages;} // importedOverlays;

    # reusable modules
    nixosModules = import ./modules/nixos // importedNixosModules;

    # nixos config
    nixosConfigurations = {
      toaster = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/toaster];
        # let our nixos config use our overlays and modules
        specialArgs = {inherit (self.outputs) overlays nixosModules;};
      };
    };
  };
}
