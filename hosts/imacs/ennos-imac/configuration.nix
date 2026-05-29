{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-hidpi
    ./hardware-configuration.nix
    ./services/minecraftServers.nix
  ];

  boot = {
    initrd.kernelModules = [
      "applesmc"
      "applespi"
      "intel_lpss_pci"
      "spi_pxa2xx_platform"
      "kvm-intel"
    ];
    blacklistedKernelModules = [
      "b43"
      "ssb"
      "brcmfmac"
      "brcmsmac"
      "bcma"
    ];
    kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.0") pkgs.linuxPackages_latest;
  };

  hardware = {
    bluetooth.enable = lib.mkDefault true;
  };

  networking.hostName = "ennos-imac"; # Define your hostname.
  networking.hostId = "10c0a214";
}
