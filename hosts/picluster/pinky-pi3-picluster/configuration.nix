{ lib, pkgs, ... }:{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    grub.enable = lib.mkDefault false;
    generic-extlinux-compatible.enable = lib.mkDefault true;
  };

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "pinky-pi3-picluster"; # Define your hostname.

  boot.initrd.availableKernelModules = [ "usbhid" ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  networking.useDHCP = lib.mkDefault true;
}
