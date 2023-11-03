{pkgs, inputs, ...}: {

  programs.hyprland.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = [
    pkgs.hyprland-share-picker
  ];
}
