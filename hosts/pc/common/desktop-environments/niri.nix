{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [inputs.niri-flake.overlays.niri];
  imports = [
    inputs.clipboard-sync.nixosModules.default
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  niri-flake.cache.enable = true;

  services.displayManager.cosmic-greeter.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gvfs.enable = true;

  xdg.portal = {
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-cosmic
      pkgs.xdg-desktop-portal-gnome
    ];
  };

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
    inputs.niri-flake.packages.${stdenv.hostPlatform.system}.xwayland-satellite-unstable
    file-roller
    nautilus
    waypaper
    glib

    cosmic-edit
    networkmanagerapplet
    pop-icon-theme
  ];
}
