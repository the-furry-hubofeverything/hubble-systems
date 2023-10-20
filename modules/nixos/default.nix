# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;

  nix-alien = import ./nix-alien.nix;
  flamenco = import ./flamenco.nix;
  hyprland = import ./hyprland.nix;
  kdeconnect = import ./kdeconnect.nix;
  lanzaboote = import ./lanzaboote.nix;
  virt-manager = import ./virt-manager.nix;
  waydroid = import ./waydroid.nix;
  wireshark = import ./wireshark.nix;
}
