{
  imports = [
    ../common.nix
  ];
  boot.loader.raspberryPi.version = 3;
  hardware.enableRedistributableFirmware = true;
}
