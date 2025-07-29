{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri-flake.homeModules.niri
  ];
  nixpkgs.overlays = [inputs.niri-flake.overlays.niri];

  programs.niri = {
    enable = true;
    config = null;
    package = pkgs.niri-unstable;
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

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
    pkgs.pwvucontrol
    pkgs.wdisplays
    pkgs.waybar
    pkgs.mako
    pkgs.swaynotificationcenter
  ];
}
