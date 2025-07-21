{
  description = "KnoxOS as a Nix flake";

  inputs = {
    # pinned to stable for now
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # home directory management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    home-manager,
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
  in {
    # custom packages
    packages = forAllSystems (system: enumerateCustomPackages nixpkgs.legacyPackages.${system});

    # custom nixpkgs overlays, mainly for using with our primary configurations
    overlays = import ./overlays {inherit enumerateCustomPackages;} // importedOverlays;

    # nixos config
    nixosConfigurations = {
      toaster = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/toaster
          nix-index-database.nixosModules.nix-index
          # home manager initialization as a NixOS module
          home-manager.nixosModules.home-manager
          {
            # follow nixos nixpkgs, which will cause the "nixpkgs" option in the home-manager config to be ignored
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.knox = import ./homes/knox;
          }
          # so nixos and home-manager have access to our custom packages
          { nixpkgs.overlays = nixpkgs.lib.attrsets.attrValues self.outputs.overlays; }
        ];
      };
    };
  };
}
