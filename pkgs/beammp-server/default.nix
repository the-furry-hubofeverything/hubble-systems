{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  lua5_3,
  openssl,
  curl,
  git,
  gnat,
  zlib,
  boost,
  websocketpp,
}:
stdenv.mkDerivation rec {
  pname = "beammp-server";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "BeamMP";
    repo = "BeamMP-Server";
    rev = "v${version}";
    hash = "sha256-BbQidAaj1OT0cBatL1+1vIJwWBWtRcECs/9Jz11WaUI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    lua5_3
    openssl
    curl
    git
    gnat
    zlib
    boost
    websocketpp
  ];

  configurePhase = ''
    cmake . -Wno-dev -DGIT_SUBMODULE=OFF -DCMAKE_BUILD_TYPE=Release
  '';

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -v BeamMP-Server $out/bin
  '';

  meta = with lib; {
    description = "Server for the multiplayer mod BeamMP for BeamNG.drive";
    homepage = "https://github.com/BeamMP/BeamMP-Server";
    changelog = "https://github.com/BeamMP/BeamMP-Server/blob/${src.rev}/Changelog.md";
    broken = true; # Potential license conflict
    license = with licenses; [unfree];
    maintainers = with maintainers; [];
  };
}
