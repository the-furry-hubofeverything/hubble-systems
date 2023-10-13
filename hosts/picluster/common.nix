{
  inputs,
  lib,
  ...
}: {
  imports = [
    #   "${inputs.nixpkgs.sourceInfo.outPath}/nixos/modules/profiles/graphical.nix"
    ../common/nix-settings.nix
    ../common/hubbleGroups.nix
    ../common/security.nix
  ];

  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
  '';

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # TODO setup HA services
}
