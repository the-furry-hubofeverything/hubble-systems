# PC common configs
{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc

    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr

    ./pc.nix
    ./gaming.nix
    ./performance-tweaks.nix
    ./security.nix
    ./wayland.nix
    ./pipewire.nix

    ./desktop-environments/gnome.nix

    ./hardware/logitechWheelSupport.nix
    # ./hardware/VR.nix

    ./programs/kdeconnect.nix
    ./programs/lanzaboote.nix
    ./programs/libvirt.nix
    ./programs/nix-alien.nix

    ../../common/security.nix
    ../../common/nix-settings.nix
    ../../common/development.nix
    ../../common/hubbleGroups.nix
    ../../common/bash-config.nix
    ../../common/network-tuning.nix

    outputs.nixosModules.flamenco
    ../../common/services/flamenco.nix

    ../../common/services/nebula.nix
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
