{lib, ...}: {
  imports = [
    ../../common/servers
    ../../common/nix-settings.nix
    ../../common/hubbleGroups.nix
    ../../common/security.nix
    ../../common/development.nix
    ../../common/bash-config.nix
    ../../common/network-tuning.nix

    ../../common/services/nebula.nix
    ../../common/services/monitoring.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Phoenix";

  boot.loader.systemd-boot.configurationLimit = 3;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Distribute irq over multiple cores
  services.irqbalance.enable = true;
  
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
