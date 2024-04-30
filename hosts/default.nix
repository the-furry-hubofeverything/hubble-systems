{
  inputs,
  lib,
  outputs,
}: let
  # for *-common configurations
  commonVMConfig = {
    networking.hostId = "356876b4";
    fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    boot.loader.grub.device = lib.mkDefault "/dev/sda";

    # We place down a empty file just so we can test and workaround
    # the fact that we don't actually have default secrets
    sops.defaultSopsFile = ./common/.sops.yaml;
  };

  sharedModules = [
    inputs.sops-nix.nixosModules.sops
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
  ];
in {
  # TODO: use *-common configs to easily replicate configs for debugging instead of machine specific ones.
  # That way, we all can use a VM to see if we can replicate a bug, without worrying about machine specifics.

  # === Pi cluster ===
  inherit
    (import ./picluster {inherit commonVMConfig inputs outputs sharedModules;})
    picluster-common
    brain-pi4-picluster
    pinky-pi3-picluster
    ;

  # === Laptop cluster ===
  inherit
    (import ./lcluster {inherit commonVMConfig inputs outputs sharedModules;})
    # lcluster-common #Issue - acme-nginx-rp requires secrets, and many services depend on it so...
    
    enterprise-asus-lcluster
    titan-razer-lcluster
    ;

  # === Personal computers ===
  inherit
    (import ./pc {inherit commonVMConfig inputs outputs sharedModules;})
    pc-common
    Gulo-Laptop
    ;

  # === Remote servers ===
  inherit
    (import ./remote {inherit commonVMConfig inputs outputs sharedModules;})
    remote-common
    alex-oracle-remote
    alan-google-remote
    ;
}
