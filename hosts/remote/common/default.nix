{ ... }: {
  imports = [
    ../../common/servers
    ../../common/services/nebula.nix
    ../../common/nix-settings.nix
    ../../common/hubbleGroups.nix
    ../../common/security.nix
    ../../common/development.nix
    ../../common/bash-config.nix
    ../../common/network-tuning.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Phoenix";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Distribute irq over multiple cores
  services.irqbalance.enable = true;

}