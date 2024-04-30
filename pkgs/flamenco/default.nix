{
  lib,
  buildGoModule,
  fetchFromGitea,
  fetchYarnDeps,
  makeWrapper,
  blender,
  ffmpeg,
  go,
  oapi-codegen,
  mockgen,
  nodejs,
  yarn,
  prefetch-yarn-deps,
}: let
  version = "3.5";
in
  buildGoModule rec {
    pname = "flamenco";
    inherit version;

    # !!!!!!!!!
    # fixup-yarn-lock HAS BEEN REMOVED
    # TODO CHANGE WHEN UPSTREAMING/UPDATING TO 24.05+
    # !!!!!!!!!

    src = fetchFromGitea {
      domain = "projects.blender.org";
      owner = "studio";
      repo = "flamenco";
      rev = "v${version}";
      hash = "sha256-iAMQv4GzxS5PPQPrLCjBj7qd2HpAg91/BtMRoGTuJ5U=";
    };

    patches = [
      ./absolute-path-bypass.patch
    ];

    webappOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/web/app/yarn.lock";
      hash = "sha256-QcfyiL2/ALkxZpJyiwyD7xNlkOCPu4THCyywwZ40H8s=";
    };

    vendorHash = "sha256-DJooc+rGQ61lxjqP5+5eyQe7x69R3ADOwHDMu6NbICQ=";

    nativeBuildInputs = [
      makeWrapper
      go
      oapi-codegen
      mockgen
      nodejs
      yarn
      prefetch-yarn-deps
    ];

    buildInputs = [
      blender
      ffmpeg
    ];

    postConfigure = ''
      export HOME=$(mktemp -d)
      yarn config --offline set yarn-offline-mirror ${webappOfflineCache}
      fixup-yarn-lock web/app/yarn.lock
      cd web/app && yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install && cd ../..
      patchShebangs web
    '';

    buildPhase = ''
      runHook preBuild

      make -s webapp-static
      make -s flamenco-manager-without-webapp GOOS=linux GOARCH=amd64
      make -s flamenco-worker GOOS=linux GOARCH=amd64

      runHook postBuild
    '';

    postInstall = ''
      mkdir -p "$out/bin"
      cp flamenco-manager flamenco-worker $out/bin
    '';

    postFixup = ''
      for f in $out/bin/*
      do
        wrapProgram $f \
          --set PATH ${lib.makeBinPath [
        blender
        ffmpeg
      ]}
      done
    '';

    meta = {
      description = "Production render farm manager for Blender";
      homepage = "https://flamenco.blender.org/";
      license = lib.licenses.gpl3Only;
      # TODO Wanted: maintainer for darwin
      platforms = ["x86_64-linux"];
      maintainers = with lib.maintainers; [hubble];
    };
  }
