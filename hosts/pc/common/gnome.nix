{
  config,
  pkgs,
  outputs,
  ...
}: {

  disabledModules = [ "services/desktops/gnome/tracker-miners.nix" ];
  imports = [
    outputs.nixosModules.tracker-miners
  ];

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

  programs.dconf.enable = true;

  security.pam.services.gdm.enableGnomeKeyring = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    excludePackages = [pkgs.xterm pkgs.gnome.gnome-terminal];
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.pop-shell

    gnome.gnome-tweaks
    gnome.adwaita-icon-theme

    desktop-file-utils

    polkit_gnome
  ];

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      gnome-music
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      tali # poker game
      iagno # go game
      cheese
      gnome-terminal
    ]);

  programs.gnome-terminal.enable = false;

  # udev rule for primary gpu selection with mutter
  services.udev.extraRules = ''
    ENV{DEVNAME}=="/dev/dri/card0", TAG+="mutter-device-preferred-primary"
  '';

  # GNOME integration for dual gpu
  services.switcherooControl.enable = true;

  # tracker-miner workaround 
  services.gnome.tracker-miners = {
    enable = true;
    package =
    pkgs.unstable.tracker-miners.overrideAttrs (attrs: {
      version = "3.5.4";
      src = pkgs.fetchurl {
        url = "mirror://gnome/sources/tracker-miners/3.5/tracker-miners-3.5.4.tar.xz";
        hash = "sha256-YC/wIeZuPXI9qlrt3KqOfGpQEVSW5M5QfX9enWe2qAs=";
      };
    });
  };
}
