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

  niri-flake.cache.enable = true;

  services.displayManager.cosmic-greeter.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gvfs.enable = true;

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  environment.variables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    gamescope
    inputs.niri-flake.packages.${stdenv.hostPlatform.system}.xwayland-satellite-unstable
    file-roller
    unstable.waypaper
    glib


    cosmic-files
    cosmic-edit
    cosmic-icons
    cosmic-player
    cosmic-randr
    cosmic-screenshot
    cosmic-term
    cosmic-wallpapers
    networkmanagerapplet
    pop-icon-theme
];
}
