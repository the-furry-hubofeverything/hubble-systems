{config, ...}: {
  # Xbox controller driver
  hardware.xpadneo.enable = true;
  boot.extraModprobeConfig = '' options bluetooth disable_ertm=1 '';
}