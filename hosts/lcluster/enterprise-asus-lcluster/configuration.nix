{
  imports = [
    ./hardware-configuration.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "enterprise-asus-lcluster"; # Define your hostname.

  system.stateVersion = "23.05";
}
