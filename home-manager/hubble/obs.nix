{ pkgs, lib, ... }: {
  programs.obs-studio = {
    enable = true;
    package = (pkgs.obs-studio.overrideAttrs (_: prev: {
      cmakeFlags = prev.cmakeFlags ++ [ "-DENABLE_LIBFDK=ON" ];
    }));
    plugins = with pkgs; [
      obs-studio-plugins.obs-tuna
      obs-studio-plugins.obs-vaapi
      obs-studio-plugins.obs-vkcapture
      obs-studio-plugins.looking-glass-obs
    ];
  };
}