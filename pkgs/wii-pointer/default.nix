{ 
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
  ... 
}: 

stdenvNoCC.mkDerivation {
  name = "wii-pointer";
  version = "2024-03-31";

  src = fetchurl {
    name = "linux-cursors.7z";
    url = "https://files.primm.gay/extras/cursors/Wii/Linux%20Cursors.7z";
    hash = "sha256-1lFJrLYEyT1STLgK1YOpy/g4tgGk/ENnri5QjR0dMzo=";
  };

  unpackPhase = ''
    ${p7zip}/bin/7z x $src
  '';

  installPhase = ''
    install -dm 755 $out/share/icons
    cp -dr --no-preserve='ownership' 'Linux Cursor/Wii-Pointer' $out/share/icons/
  '';

  meta = with lib; {
    description = "Wii pointer cursor theme";
    homepage = "https://primm.gay/extras/other/cursors/";
    # From README.txt - Feel free to use this set for whatever you want, but please seek my permission if you wish to redistribute it.
    # Since there's no mention of a specific license, I'm going to set this to unfree
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ hubble ];
  };
}