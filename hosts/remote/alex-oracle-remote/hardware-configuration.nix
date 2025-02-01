{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3514fba9-d07a-457f-bb6f-0fe8d817b681";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9654-DFA0";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3514fba9-d07a-457f-bb6f-0fe8d817b681";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/3514fba9-d07a-457f-bb6f-0fe8d817b681";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/3514fba9-d07a-457f-bb6f-0fe8d817b681";
    fsType = "btrfs";
    neededForBoot = true;
    options = ["subvol=persist" "compress=zstd" "noatime"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/3514fba9-d07a-457f-bb6f-0fe8d817b681";
    fsType = "btrfs";
    options = ["subvol=log" "compress=zstd" "noatime"];
  };

  swapDevices = [{device = "/dev/disk/by-uuid/6c7bb137-82cd-4322-8a0b-e10cd66c4f44";}];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_scsi" ];
  boot.initrd.kernelModules = ["nvme"];
  nixpkgs.hostPlatform = "aarch64-linux";
}
