{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
  player,
  ...
}: let
  build = player:
    stdenvNoCC.mkDerivation {
      name = "wii-pointer";
      version = "2024-04-02";

      src = fetchurl {
        name = "linux-cursors.7z";
        url = "https://files.primm.gay/extras/cursors/Wii/Linux%20Cursors.7z";
        hash = "sha256-M8cerLpAlkKvCqNZU5w4UtIP3nxjeHopa4wNmlxnG5k=";
      };

      unpackPhase = ''
        ${p7zip}/bin/7z x $src
      '';

      installPhase = ''
        install -dm 755 $out/share/icons
        cp -dr --no-preserve='ownership' 'Linux Cursor/Wii-Pointer-P${toString player}' $out/share/icons/
      '';

      meta = {
        description = "Wii pointer cursor theme (Player ${toString player})";
        homepage = "https://primm.gay/extras/other/cursors/";
        # From README.txt - Feel free to use these wherever you want, as long as it's for non-commercial use.
        # And finally, credit of any form would also be greatly appreciated if you use these in a public distribution!
        license = lib.licenses.unfree;
        platforms = lib.platforms.all;
        maintainers = with lib.maintainers; [hubble];
      };
    };
in
  build player
