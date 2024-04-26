{
  inputs,
  outputs,
}: let
  nixos-hardware = inputs.hardware.nixosModules;

  # Host ID for *-common configurations
  hostId-common = { networking.hostId = "356876b4"; };

  sharedModules = [
    inputs.sops-nix.nixosModules.sops
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
  ];

in {
  # TODO: use *-common configs to easily replicate configs for debugging instead of machine specific ones.
  # That way, we all can use a VM to see if we can replicate a bug, without worrying about machine specifics.

  # === Pi cluster ===
  inherit (import ./picluster {inherit hostId-common inputs outputs sharedModules;})
    picluster-common
    picluster-sd-installer
    brain-pi4-picluster
    pinky-pi3-picluster;

  # === Laptop cluster ===
  inherit (import ./lcluster {inherit hostId-common inputs outputs sharedModules;}) 
    lcluster-common
    enterprise-asus-lcluster
    titan-razer-lcluster;

  # === Personal computers ===
  inherit (import ./pc {inherit hostId-common inputs outputs sharedModules;})
    pc-common
    Gulo-Laptop;

  # === Remote servers ===
  inherit (import ./remote {inherit hostId-common inputs outputs sharedModules;})
    remote-common
    alex-oracle-remote
    alan-google-remote;
}
