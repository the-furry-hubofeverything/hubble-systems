{
  inputs,
  outputs,
}: let
  nixos-hardware = inputs.hardware.nixosModules;
in {
  # Common modules
  modules = [
    nixos-hardware.common-pc
    nixos-hardware.common-pc-hdd
    nixos-hardware.common-pc-ssd
    nixos-hardware.common-pc-laptop
    nixos-hardware.common-pc-laptop-hdd
  ];
}
