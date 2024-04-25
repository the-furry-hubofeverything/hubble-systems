{
  inputs,
  lib,
  ...
}: {
  imports = [
    #   "${inputs.nixpkgs.sourceInfo.outPath}/nixos/modules/profiles/graphical.nix"
    ../../common/nix-settings.nix
    ../../common/hubbleGroups.nix
    ../../common/security.nix
    ../../common/bash-config.nix
    ../../common/network-tuning.nix

    # nebula
    ../../common/services/nebula.nix

    ../../common/servers
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.configurationLimit = 3;

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [];

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

  system.stateVersion = "23.11";
}
