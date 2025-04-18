{
  lib,
  buildGoModule,
  fetchFromGitea,
  fetchYarnDeps,
  fixup-yarn-lock,
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
  version = "3.7";
in
  buildGoModule rec {
    pname = "flamenco";
    inherit version;

    src = fetchFromGitea {
      domain = "projects.blender.org";
      owner = "studio";
      repo = "flamenco";
      tag = "v${version}";
      # from nixos/nixpkgs#387031
      leaveDotGit = true;
      # Only keep HEAD, because leaveDotGit is non-deterministic:
      # https://github.com/NixOS/nixpkgs/issues/8567
      postFetch = ''
        hash=$(git -C "$out" rev-parse --short=9 HEAD)
        rm -r "$out"/.git
        echo "$hash" > "$out"/HEAD
      '';
      hash = "sha256-LJo+yPxT3tWG8bbvKnvJQAs1c47IE5mzA2HznQdGRBQ=";
    };

    patches = [
      ./absolute-path-bypass.patch
      ./githash.patch
    ];

    webappOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/web/app/yarn.lock";
      hash = "sha256-QcfyiL2/ALkxZpJyiwyD7xNlkOCPu4THCyywwZ40H8s=";
    };

    vendorHash = "sha256-0q+wMisKmVZuTp1VdJ7GM1xiHM2FJAF0O6IiuwsK3e4=";

    nativeBuildInputs = [
      makeWrapper
      go
      oapi-codegen
      mockgen
      nodejs
      yarn
      prefetch-yarn-deps
      fixup-yarn-lock
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

    makeFlags = [
      "GITHASH=$(cat ${src}/HEAD)"
      "GOOS=linux"
      "GOARCH=amd64"
    ];

    buildPhase = ''
      runHook preBuild
      export npm_config_offline=true

      make -s webapp-static 
      make -s flamenco-manager-without-webapp
      make -s flamenco-worker
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
