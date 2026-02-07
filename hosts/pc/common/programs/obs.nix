{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
    enableVirtualCamera = true;
    plugins = with pkgs; [
      obs-studio-plugins.obs-tuna
      obs-studio-plugins.obs-vaapi
      obs-studio-plugins.obs-vkcapture
      obs-studio-plugins.obs-pipewire-audio-capture
      obs-studio-plugins.looking-glass-obs
      obs-studio-plugins.obs-gstreamer
      obs-studio-plugins.obs-source-clone
      obs-studio-plugins.obs-composite-blur
      obs-studio-plugins.obs-stroke-glow-shadow
    ];
  };
}
