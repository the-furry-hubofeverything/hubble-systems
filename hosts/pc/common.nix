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

    ./common/desktop-environments/gnome.nix

    ./common/hardware/logitechWheelSupport.nix
    ./common/hardware/VR.nix

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
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };

  system.stateVersion = "23.05";
}
