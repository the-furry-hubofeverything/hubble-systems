# PC common configs
{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./common/pc.nix
    ./common/gaming.nix
    ./common/performance-tweaks.nix
    ./common/security.nix
    ./common/wayland.nix

    # ./common/desktop-environments/hyprland.nix
    ./common/desktop-environments/gnome.nix

    ./common/hardware/logitechWheelSupport.nix

    ./common/programs/kdeconnect.nix
    ./common/programs/lanzaboote.nix
    ./common/programs/libvirt.nix
    ./common/programs/nix-alien.nix

    ../common/security.nix
    ../common/nix-settings.nix
    ../common/development.nix
    ../common/hubbleGroups.nix
    ../common/bash-config.nix
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
