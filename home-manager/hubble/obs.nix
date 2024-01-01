{ pkgs, lib, ... }: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [
      obs-studio-plugins.obs-tuna
      obs-studio-plugins.obs-vaapi
      obs-studio-plugins.obs-vkcapture
    ] ++ lib.optional builtins.elem pkgs.looking-glass-client config.environment.systemPackages [obs-studio-plugins.looking-glass-obs];
  };
}