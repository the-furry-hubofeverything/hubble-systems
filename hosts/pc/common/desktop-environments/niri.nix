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
  services.power-profiles-daemon.enable = true;
  services.gvfs.enable = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };


  environment.variables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    gamescope
    xwayland-satellite
    nautilus
    file-roller
    gnome-text-editor
    unstable.waypaper
    glib
  ];
}
