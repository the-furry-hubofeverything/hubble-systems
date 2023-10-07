{
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    ./common/server.nix

    ../common/nix-settings.nix
    ../common/hubbleGroups.nix
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

  # TODO Setup HA sevices
}
