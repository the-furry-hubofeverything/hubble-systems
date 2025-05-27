{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [inputs.niri-flake.overlays.niri];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  services.xserver.displayManager.gdm.enable = true;

  environment.variables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    gamescope
    xwayland-satellite
    unstable.waypaper
  ];
}
