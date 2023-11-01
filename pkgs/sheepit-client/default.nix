{ lib
, stdenv
, fetchFromGitLab
, jdk
, gradle_7
}:

stdenv.mkDerivation rec {
  pname = "sheepit-client";
  version = "6.22274.0";

  src = fetchFromGitLab {
    owner = "sheepitrenderfarm";
    repo = "client";
    rev = "v${version}";
    hash = "sha256-u3DMThqj5KDQEV7iDwiJcUMelTVIXl3qhCTRcjCSl/s=";
  };

  # TODO gradle is such a pain in the butt
  nativeBuildInputs = [ jdk gradle_7 ];

  buildPhase = ''
    runHook preBuild

    ./gradlew --no-daemon build

    runHook postBuild
  '';

  postInstall = ''
    mkdir -p "$out/bin"
    cp build/libs/sheepit-client-all.jar $out/bin
  '';

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.com/sheepitrenderfarm/client/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ hubble ];
  };
}
