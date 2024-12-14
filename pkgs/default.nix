# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  beammp-server = pkgs.callPackage ./beammp-server/default.nix {};
  beammp-launcher = pkgs.callPackage ./beammp-launcher/default.nix {};
  flamenco = pkgs.callPackage ./flamenco/default.nix {};
  koulen = pkgs.callPackage ./koulen/default.nix {};
  # sheepit-client = pkgs.callPackage ./sheepit-client/default.nix {};
  wii-pointer = pkgs.callPackage ./wii-pointer/default.nix {player = 1;};
  wii-pointer-p2 = pkgs.callPackage ./wii-pointer/default.nix {player = 2;};
  wii-pointer-p3 = pkgs.callPackage ./wii-pointer/default.nix {player = 3;};
  wii-pointer-p4 = pkgs.callPackage ./wii-pointer/default.nix {player = 4;};
  # quicksand = pkgs.callPackage ./quicksand/default.nix {};
}
