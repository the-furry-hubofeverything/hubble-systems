{ inputs, pkgs, ... }:{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4
    ./hardware-configuration.nix
  ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  console.enable = false;
  networking.wireless.enable = true;

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  networking.hostName = "brain-pi4-picluster"; # Define your hostname.

  system.stateVersion = "23.05";
}
