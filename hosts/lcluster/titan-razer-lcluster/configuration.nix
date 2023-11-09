{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./services/minecraftServers.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "titan-razer-lcluster"; # Define your hostname.
  networking.hostId = "5cda25bf";

  system.stateVersion = "23.05";
}
