{ 
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
  ... 
}: 
let 
  build = player: stdenvNoCC.mkDerivation {
    name = "wii-pointer";
    version = "2024-04-02";

    src = fetchurl {
      name = "linux-cursors.7z";
      url = "https://files.primm.gay/extras/cursors/Wii/Linux%20Cursors.7z";
      hash = "sha256-ATEERNrI0zR6ZL57cL39P+2Mu/Qf2CaQjksCWZSVia8=";
    };

    unpackPhase = ''
      ${p7zip}/bin/7z x $src
    '';

    installPhase = ''
      install -dm 755 $out/share/icons
      cp -dr --no-preserve='ownership' 'Linux Cursor/Wii-Pointer-P${player}' $out/share/icons/
    '';

    meta = with lib; {
      description = "Wii pointer cursor theme (Player ${player})";
      homepage = "https://primm.gay/extras/other/cursors/";
      # From README.txt - Feel free to use this set for whatever you want, but please seek my permission if you wish to redistribute it.
      # Since there's no mention of a specific license, I'm going to set this to unfree
      license = licenses.unfree;
      platforms = platforms.all;
      maintainers = with maintainers; [ hubble ];
    };
  };
in {
  p1 = build "1";
  p2 = build "2";
  p3 = build "3";
  p4 = build "4";
}