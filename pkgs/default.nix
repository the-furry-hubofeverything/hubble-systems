# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: rec {
  # example = pkgs.callPackage ./example { };
  beammp-server = pkgs.callPackage ./beammp-server/default.nix {};
  flamenco = pkgs.callPackage ./flamenco/default.nix {};
  koulen = pkgs.callPackage ./koulen/default.nix {};
  sheepit-client = pkgs.callPackage ./sheepit-client/default.nix {};
  wii-pointer = wii-pointers.p1;
  wii-pointers = pkgs.callPackage ./wii-pointer/default.nix {};
  rtcqs = pkgs.callPackage ./rtcqs/default.nix {};
  # quicksand = pkgs.callPackage ./quicksand/default.nix {};
}
