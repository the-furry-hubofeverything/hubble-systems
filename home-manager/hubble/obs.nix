{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    plugins = with pkgs; [
      obs-studio-plugins.obs-tuna
      obs-studio-plugins.obs-vaapi
      obs-studio-plugins.obs-vkcapture
      obs-studio-plugins.obs-pipewire-audio-capture
      obs-studio-plugins.looking-glass-obs
    ];
    enableVirtualCamera = true;
  };
}
