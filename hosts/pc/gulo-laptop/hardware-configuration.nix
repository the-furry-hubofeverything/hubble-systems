# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "ahci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/17648caa-db72-4927-b733-05985a30cfd1";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-5e0abd4a-5371-4ad3-ab11-5b3035b01476".device = "/dev/disk/by-uuid/5e0abd4a-5371-4ad3-ab11-5b3035b01476";
  boot.initrd.luks.devices."luks-56d11093-118b-4120-9675-5567ed5976bd".device = "/dev/disk/by-uuid/56d11093-118b-4120-9675-5567ed5976bd";

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/4CB2-9AD4";
    fsType = "vfat";
  };

  fileSystems."/run/media/hubble/Data" = {
    device = "/dev/disk/by-uuid/aa1ff7b1-1b4f-45f7-ab3b-09bc2de9da4d";
    fsType = "ext4";
    options = ["rw" "user" "exec" "errors=remount-ro" "nofail"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/db9981d0-a352-415c-b309-ca62aebd92e2";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  # Set your system kind (needed for flakes)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
