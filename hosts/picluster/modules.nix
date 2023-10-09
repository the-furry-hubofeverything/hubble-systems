{
  inputs,
  outputs,
}: let
  nixos-hardware = inputs.hardware.nixosModules;
in {
  # Common modules
  modules = [
    inputs.sops-nix.nixosModules.sops
  ];
}
