_: {
  imports = [
    ./hardware-configuration.nix
    ./services/minecraftServers.nix
    ./services/libvirt-win10vm.nix
    ../../pc/common/programs/libvirt.nix
  ];

  hardware.nvidia = {
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    open = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "titan-razer-lcluster"; # Define your hostname.
  networking.hostId = "5cda25bf";

  system.stateVersion = "23.05";
}
