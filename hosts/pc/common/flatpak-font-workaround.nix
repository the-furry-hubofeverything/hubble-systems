{ pkgs, lib, config, ... }: {
  # https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-1326957279
  # Workaround for 119433

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    aggregatedIcons = pkgs.buildEnv {
      name = "system-icons";
      paths = if (config.services.xserver.desktopManager.gnome.enable) then lib.singleton pkgs.gnome.gnome-themes-extra else lib.singleton pkgs.libsForQt5.breeze-qt5;
      pathsToLink = [ "/share/icons" ];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.packages;
      pathsToLink = [ "/share/fonts" ];
    };
  in {
    "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
    "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
  };
  
  fonts.fontDir.enable = true;
}