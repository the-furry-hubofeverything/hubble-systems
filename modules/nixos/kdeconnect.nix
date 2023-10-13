{
  config,
  pkgs,
  ...
}: {
  # Phone connectivity
  programs.kdeconnect = {
    enable = true;
    package =
      if config.services.xservers.desktopManager.gnome.enable
      then pkgs.gnomeExtensions.gsconnect
      else config.programs.kdeconnect.package.default;
  };
}