{ ... }: {
  
  imports = [
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # Cloud console debug
  boot.kernelParams = ["console=ttyS0,9600"];

  networking.hostName = "alex-oracle-remote"; # Define your hostname.
  networking.domain = "subnet11062027.vcn11062027.oraclevcn.com";

  system.stateVersion = "23.11";
}