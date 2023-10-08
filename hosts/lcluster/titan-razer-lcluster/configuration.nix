{ config, pkgs, ... }:
{
  imports = [
    ../common.nix
    ./minecraftServers
    
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];

  networking.hostName = "titan-razer-lcluster"; # Define your hostname.

  system.stateVersion = "23.05";
}