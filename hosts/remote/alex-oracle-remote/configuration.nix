{ ... }: {
  
  imports = [
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.domain = "";

  networking.hostName = "alex-oracle-remote"; # Define your hostname.

  system.stateVersion = "23.05";
}