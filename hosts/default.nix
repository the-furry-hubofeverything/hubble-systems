{
  inputs,
  outputs,
}: let
  lCluster = import ./lcluster/modules.nix {inherit inputs outputs;};
  piCluster = import ./picluster/modules.nix {inherit inputs outputs;};
  pc = import ./pc/modules.nix {inherit inputs outputs;};

  nixos-hardware = inputs.hardware.nixosModules;
in {
  # TODO: use *-common configs to easily replicate configs for debugging instead of machine specific ones.
  # That way, we all can use a VM to see if we can replicate a bug, without worrying about machine specifics.

  # === Pi cluster ===
  picluster-common = {
    platform = "aarch64-linux";
    modules = piCluster.modules ++ [ ./picluster/common.nix ];
  };

  brain-pi4-picluster = {
    platform = "aarch64-linux";
    modules =
      piCluster.modules
      ++ [
        ./picluster/brain-pi4-picluster/configuration.nix
        nixos-hardware.raspberry-pi-4
      ];
  };
  pinky-pi3-piCluster = {
    platform = "aarch64-linux";
    modules =
      piCluster.modules
      ++ [
        ./picluster/pinky-pi3-picluster/configuration.nix
      ];
  };

  # === Laptop cluster ===
  lCluster-common = {
    platform = "x86_64-linux";
    modules = lCluster.modules ++ [ ./lcluster/common.nix ];
  };

  titan-razer-lcluster = {
    platform = "x86_64-linux";
    modules =
      lCluster.modules
      ++ [
        ./lcluster/titan-razer-lcluster/configuration.nix

        inputs.nix-minecraft.nixosModules.minecraft-servers
      ];
  };

  enterprise-asus-lcluster = {
    platform = "x86_64-linux";
    modules =
      lCluster.modules
      ++ [
        ./lcluster/enterprise-asus-lcluster/configuration.nix
      ];
  };

  # === Personal computers ===
  pc-common = {
    platform = "x86_64-linux";
    modules = pc.modules ++ [ ./pc/common.nix ];
  };

  Gulo-Laptop = {
    platform = "x86_64-linux";
    modules =
      pc.modules
      ++ [
        ./pc/gulo-laptop/configuration.nix
        nixos-hardware.omen-15-en0010ca

        inputs.lanzaboote.nixosModules.lanzaboote
        outputs.nixosModules.wireshark
        outputs.nixosModules.lanzaboote
        outputs.nixosModules.waydroid
      ];
  };
}
