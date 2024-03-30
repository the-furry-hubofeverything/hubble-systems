{
  inputs,
  outputs,
}: let
  nixos-hardware = inputs.hardware.nixosModules;

  sharedModules = rec {
    all = [
      inputs.sops-nix.nixosModules.sops
    ];

    lCluster = all ++ [
      ./lcluster/common.nix

      nixos-hardware.common-pc
      nixos-hardware.common-pc-hdd
      nixos-hardware.common-pc-ssd
      nixos-hardware.common-pc-laptop
      nixos-hardware.common-pc-laptop-hdd

      inputs.impermanence.nixosModules.impermanence
    ];

    piCluster = all ++ [
      ./picluster/common.nix
    ];

    pc = all ++ [
      ./pc/common.nix

      nixos-hardware.common-pc
    ];
  };
in {
  # TODO: use *-common configs to easily replicate configs for debugging instead of machine specific ones.
  # That way, we all can use a VM to see if we can replicate a bug, without worrying about machine specifics.

  # === Pi cluster ===
  picluster-common = {
    platform = "aarch64-linux";
    modules = sharedModules.piCluster ++ [./picluster/common.nix];
  };

  brain-pi4-picluster = {
    platform = "aarch64-linux";
    modules =
      sharedModules.piCluster
      ++ [
        ./picluster/brain-pi4-picluster/configuration.nix
        nixos-hardware.raspberry-pi-4
      ];
  };
  pinky-pi3-piCluster = {
    platform = "aarch64-linux";
    modules =
      sharedModules.piCluster
      ++ [
        ./picluster/pinky-pi3-picluster/configuration.nix
      ];
  };

  # === Laptop cluster ===
  lCluster-common = {
    platform = "x86_64-linux";
    modules = sharedModules.lCluster ++ [./lcluster/common.nix];
  };

  titan-razer-lcluster = {
    platform = "x86_64-linux";
    modules =
      sharedModules.lCluster
      ++ [
        ./lcluster/titan-razer-lcluster/configuration.nix
        inputs.hs-secrets.nixosModules.lcluster.titan

        inputs.nix-minecraft.nixosModules.minecraft-servers
      ];
  };

  enterprise-asus-lcluster = {
    platform = "x86_64-linux";
    modules =
      sharedModules.lCluster
      ++ [
        ./lcluster/enterprise-asus-lcluster/configuration.nix
        inputs.hs-secrets.nixosModules.lcluster.enterprise
      ];
  };

  # === Personal computers ===
  pc-common = {
    platform = "x86_64-linux";
    modules = sharedModules.pc ++ [./pc/common.nix];
  };

  Gulo-Laptop = {
    platform = "x86_64-linux";
    modules =
      sharedModules.pc
      ++ [
        ./pc/gulo-laptop/configuration.nix
        nixos-hardware.omen-15-en0010ca

        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
      ];
  };
}
