{
  config,
  pkgs,
  lib,
  ...
}: {
  # Phone connectivity
  programs.kdeconnect = {
    enable = true;
    package = lib.mkIf config.services.desktopManager.gnome.enable pkgs.gnomeExtensions.gsconnect;
  };
}
