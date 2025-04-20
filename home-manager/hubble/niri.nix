{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri-flake.homeModules.niri
  ];
  programs.niri = {
    enable = true;
    config = null;
  };

  programs.eww = {
    enable = true;
    enableBashIntegration = true;
    configDir = ./eww;
  };

  services.playerctld = {
    enable = true;
  };

  home.packages = [
    pkgs.fuzzel
    pkgs.swaybg
    pkgs.swaylock
    pkgs.playerctl
    pkgs.mako
  ];
}
