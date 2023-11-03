{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "koulen";
  version = "unstable-2021-06-07";

  src = fetchFromGitHub {
    owner = "danhhong";
    repo = "Koulen";
    rev = "387ec6f230e61fe85a90529543daeeb2a3625b7e";
    hash = "sha256-TTs/t4BgtvUqmLuh9rX6v5L4IKNqHPN4r8Mt0JIX0cE=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm444 Release/ttf/*.ttf -t $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/danhhong/Koulen";
    license = with licenses; [ ofl ];
    platforms = platforms.all;
    maintainers = with maintainers; [ hubble ];
  };
}
