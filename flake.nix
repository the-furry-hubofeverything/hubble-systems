{
  description = "Hubble's systems";

  inputs = {
    # ===  Private secrets repository ===
    # If testing configuration, please set this to your own copy of secrets.
    hs-secrets.url = "git+ssh://git@alex.gulo.dev:37084/persist/git-server/hs-secrets";

    # === Main dependencies ===
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    hardware.url = "github:nixos/nixos-hardware";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    # === NixOS related dependencies ===

    # VR related programs
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Niri scrolling desktop environment
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable"; # use our nixpkgs
      inputs.nixpkgs-stable.follows = "nixpkgs"; # use our nixpkgs
    };

    # command-not-found for Flake-based, non-channel backed NixOS systems
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";

    vps-ranges = {
      url = "github:the-furry-hubofeverything/vps-ranges";
      flake = false;
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    # Run unpatched binaries on Nix/NixOS
    nix-alien.url = "github:thiagokokada/nix-alien";
    # Nix language server
    nixd.url = "https://flakehub.com/f/nix-community/nixd/*.tar.gz";

    # === Extra software ===
    # Blender binaries
    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs"; # use our nixpkgs
    };

    # Minecraft server utils
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    # Muse sounds (experimental)
    muse-sounds-manager.url = "github:thilobillerbeck/muse-sounds-manager-nix";
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
    hosts = import ./hosts {
      inherit inputs outputs;
      lib = nixpkgs.lib;
    };
    users = import ./home-manager {};

    # Helper Functions
    hs-utils = import ./utils nixpkgs.lib;

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllPlatforms = nixpkgs.lib.genAttrs platforms;
  in {
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
        hostname: host:
          nixpkgs.lib.nixosSystem {
            system = host.platform;
            specialArgs = {inherit hs-utils hostname inputs outputs;};
            inherit (host) modules;
          }
      )
      hosts;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    # TODO Setup home-managerfor multi host
    homeConfigurations =
      nixpkgs.lib.mapAttrs (
        _user: home:
          home-manager.lib.homeManagerConfiguration {
            # Home-manager requires 'pkgs' instance
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = {inherit inputs outputs;};
            modules = [
              home
            ];
          }
      )
      users;
  };
}
