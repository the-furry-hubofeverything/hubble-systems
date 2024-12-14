{
  lib,
  stdenv,
  fetchFromGitHub,
  vcpkg,
  httplib,
  openssl,
  nlohmann_json,
  curl,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "beammp-launcher";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "BeamMP";
    repo = "BeamMP-Launcher";
    rev = "v${version}";
    hash = "sha256-1oaTw6fNiDxhhgkqpAAocKtxvRd2RR2MM55NDWjZ1TA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    vcpkg
    httplib
    openssl
    nlohmann_json
    curl
    cmake
  ];

  cmakeBuildType = "Release";

  installPhase = ''
    mkdir -p $out/bin
    cp -v BeamMP-Launcher $out/bin
  '';

  meta = {
    description = "Official BeamMP Launcher";
    homepage = "https://github.com/BeamMP/BeamMP-Launcher.git";
    license = lib.licenses.unfree;
    mainProgram = "beammp-launcher";
    platforms = lib.platforms.all;
  };
}
