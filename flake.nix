{
  description = "Hubble's systems";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    hardware.url = "github:nixos/nixos-hardware";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    # Blender binaries
    blender-bin = {
      url = "github:the-furry-hubofeverything/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    # Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    nix-colors.url = "github:misterio77/nix-colors";

    # Run unpatched binaries on Nix/NixOS
    nix-alien.url = "github:thiagokokada/nix-alien";
    # Nix language server
    nixd.url = "github:nix-community/nixd/release/1.2";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    platforms = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];

    # individual machines setup in ./hosts
    hosts = import ./hosts {inherit inputs outputs;};

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllPlatforms = nixpkgs.lib.genAttrs platforms;
  in {
    # TODO add nix-colors
    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    packages = forAllPlatforms (platform: import ./pkgs nixpkgs.legacyPackages.${platform});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllPlatforms (platform: nixpkgs.legacyPackages.${platform}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    # Iterates through hosts/default.nix
    nixosConfigurations =
      nixpkgs.lib.mapAttrs (
        _hostname: host:
          nixpkgs.lib.nixosSystem {
            system = host.platform;
            specialArgs = {inherit inputs outputs;};
            modules = host.modules;
          }
      )
      hosts;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    # TODO Setup home-manager
    homeConfigurations = {
      "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/home.nix
        ];
      };
    };
  };
}
