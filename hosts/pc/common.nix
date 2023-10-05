# PC common configs
{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./common/desktop.nix
    ./common/development.nix
    ./common/performance-tweaks.nix
    ./common/security.nix

    ../common/nix-settings.nix
    ../common/hubbleGroups.nix

    # ../common/
  ];
  boot.loader.systemd-boot.configurationLimit = 3;

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  i18n.supportedLocales = [
    #    "en_CA.UTF-8/UTF-8"
    #    "zh_CN.UTF-8/UTF-8"
    "all"
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # === NIX SETTINGS ===
  nixpkgs = {
    overlays = [
      inputs.nixd.overlays.default
    ];
  };

  nix = {
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };
}
