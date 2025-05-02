{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    package = pkgs.unstable.obs-studio;
    plugins = with pkgs.unstable; [
      obs-studio-plugins.obs-tuna
      obs-studio-plugins.obs-vaapi
      obs-studio-plugins.obs-vkcapture
      (obs-studio-plugins.looking-glass-obs.overrideAttrs (final: prev: {
        nativeBuildInputs =
          prev.nativeBuildInputs
          ++ [
            pkgs.unstable.libGL
          ];
      }))
    ];
  };
}
