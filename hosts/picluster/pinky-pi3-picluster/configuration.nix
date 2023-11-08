{ lib, pkgs, ... }:{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.enableRedistributableFirmware = true;
  networking.wireless.enable = true;

  networking.hostName = "pinky-pi3-picluster"; # Define your hostname.

  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.useDHCP = lib.mkDefault true;

  system.stateVersion = "23.05";
}
