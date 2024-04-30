{
  pkgs,
  lib,
  ...
}: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [
      obs-studio-plugins.obs-tuna
      obs-studio-plugins.obs-vaapi
      obs-studio-plugins.obs-vkcapture
      obs-studio-plugins.looking-glass-obs
    ];
  };
}
