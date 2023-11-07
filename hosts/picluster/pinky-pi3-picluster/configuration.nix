{ ... }:{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.enableRedistributableFirmware = true;
  networking.wireless.enable = true;
  
  networking.hostName = "pinky-pi3-picluster"; # Define your hostname.
}
