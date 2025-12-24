{
  inputs,
  outputs,
  lib,
  ...
}: let
  nixos-hardware = inputs.hardware.nixosModules;
in {
  imports = [
    nixos-hardware.common-pc
    nixos-hardware.common-pc-ssd
    nixos-hardware.common-pc-laptop

    inputs.impermanence.nixosModules.impermanence

    # ACME+nginx reverse proxy
    ./services/acme-nginx-rp.nix

    # DNS server/ad-blocker with DoH
    ./services/blocky.nix

    # k3s
    # ./services/k3s.nix

    # sheepit-client
    # ./services/sheepit.nix

    # flamenco
    # outputs.nixosModules.flamenco
    # ../../common/services/flamenco.nix

    # nebula
    ../../common/services/nebula.nix

    ../../common/services/monitoring.nix
    
    ../../common/services/nix-builder.nix

    ../../common/servers
    ../../common/servers/avahi.nix

    ../../common/impermanence.nix
    ../../common/nix-settings.nix
    ../../common/hubbleGroups.nix
    ../../common/development.nix
    ../../common/security.nix
    ../../common/bash-config.nix
    ../../common/network-tuning.nix

    ../../common/filesystems/btrfs-with-rollback.nix
    ../../common/filesystems/mergerfs.nix
    ../../common/filesystems/zfs.nix
  ];
  # TODO implement auto update to github flake, add action to update flake.lock
  # system.autoUpgrade.enable = true;
  # Set your time zone.
  time.timeZone = "America/Vancouver";

  boot.loader.systemd-boot.configurationLimit = 3;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nix = {
    settings = {
      substituters = [
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };
  # === PERFORMANCE TWEAKS ===

  # CPU thermal
  services.thermald.enable = true;

  # Distribute irq over multiple cores
  services.irqbalance.enable = true;

  # OpenGL for hardware accelerated tasks
  hardware.graphics = {
    enable = true;
    # Vulkan support
    enable32Bit = true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  # === OTHER TWEAKS ===
  # As they are going to be sitting on a shelf (not to mention without internal HDDs),
  # Active drive protection is not necessary
  services.hdapsd.enable = false;

  boot.kernelModules = [
    # Filesystems I'd likely to be working with
    "ntfs3"
    "ext4"
    "btrfs"
    "zfs"
    # "bcachefs"
  ];

  # Manually override swraid to be disabled, since I'm not using it and it's enabled by default with stateVersion < 23.11
  boot.swraid.enable = false;

  # Disallow any SSH connections except from nebula or local subnet
  services.openssh.extraConfig = lib.mkOrder 100 ''
    Match Address !192.168.88.0/24,!10.86.87.0/24,!10.86.127.0/24
      AllowUsers !*
  '';

  # TODO Setup HA sevices

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
