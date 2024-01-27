# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  beammp-server = pkgs.callPackage ./beammp-server/default.nix {};
  flamenco = pkgs.callPackage ./flamenco/default.nix {};
  koulen = pkgs.callPackage ./koulen/default.nix {};
  sheepit-client = pkgs.callPackage ./sheepit-client/default.nix {};
  # quicksand = pkgs.callPackage ./quicksand/default.nix {};
}
