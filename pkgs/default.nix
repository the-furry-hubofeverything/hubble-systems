# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  xwaylandvideobridge = pkgs.libsForQt5.callPackage ./xwaylandvideobridge/default.nix {};
  beammp-server = pkgs.callPackage ./beammp-server/default.nix {};
  flamenco = pkgs.callPackage ./flamenco/default.nix {};
}
