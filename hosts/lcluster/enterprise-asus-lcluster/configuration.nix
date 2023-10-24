{
  imports = [
    ../common.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["btrfs"];

  networking.hostName = "enterprise-asus-lcluster"; # Define your hostname.

  system.stateVersion = "23.05";
}
