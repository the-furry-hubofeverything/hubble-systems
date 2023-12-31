{
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    ./common/server.nix
    ./common/security.nix
    ./common/impermanence.nix

    # ACME+nginx reverse proxy   
    ./common/services/acme-nginx-rp.nix

    # DNS server/ad-blocker with DoH
    ./common/services/blocky.nix

    # k3s
    # ./common/services/k3s.nix

    # sheepit-client
    ./common/services/sheepit.nix

    ../common/nix-settings.nix
    ../common/hubbleGroups.nix
    ../common/development.nix
    ../common/security.nix
    ../common/bash-config.nix

    ../common/filesystems/btrfs-with-rollback.nix
    ../common/filesystems/mergerfs.nix
    ../common/filesystems/zfs.nix
  ];
  # TODO implement auto update to github flake, add action to update flake.lock
  # system.autoUpgrade.enable = true;
  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
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
  hardware.opengl = {
    enable = true;
    # Vulkan support
    driSupport = true;
    driSupport32Bit = true;
  };

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

  # TODO Setup HA sevices
}
