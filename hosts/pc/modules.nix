{
  inputs,
  outputs,
}: let
  nixos-hardware = inputs.hardware.nixosModules;
in {
  # Common modules
  modules = [
    nixos-hardware.common-pc
    outputs.nixosModules.nix-alien
  ];
}
