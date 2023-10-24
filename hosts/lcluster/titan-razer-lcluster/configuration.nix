{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./minecraftServers
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["btrfs"];

  networking.hostName = "titan-razer-lcluster"; # Define your hostname.

  system.stateVersion = "23.05";
}
