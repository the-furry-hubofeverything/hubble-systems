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
    (pkgs.waybar.override { stdenv = pkgs.gcc16Stdenv; }) # fix tz issue by changing gcc to 16.2+
    pkgs.swaynotificationcenter
    pkgs.adw-bluetooth
    pkgs.labwc
  ];
}
