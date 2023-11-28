{
  config,
  pkgs,
  outputs,
  ...
}: {

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

  programs.dconf.enable = true;

  security.pam.services.gdm.enableGnomeKeyring = true;

  # KMS thread workaround
  environment.variables = {
    MUTTER_DEBUG_KMS_THREAD_TYPE = "user";
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    excludePackages = [pkgs.xterm pkgs.gnome.gnome-terminal];
    displayManager.defaultSession = "gnome";
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
}
