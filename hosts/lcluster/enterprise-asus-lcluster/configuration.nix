{
  imports = [
    ./hardware-configuration.nix
    ../../common/services/wg.nix
    ./services/nas.nix
    ./services/grocy.nix
    ./services/vaultwarden.nix
    ./services/git.nix
    ./services/kopia.nix
    ./services/monitoring.nix
    ./services/leantime.nix
  ];

  hardware.nvidia = {
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    open = false;
  };
  networking.nat.externalInterface = "enp3s0";
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "enterprise-asus-lcluster"; # Define your hostname.
  networking.hostId = "220895a0";

  system.stateVersion = "23.05";
}
