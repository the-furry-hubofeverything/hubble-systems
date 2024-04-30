{
  lib,
  stdenv,
  fetchFromGitLab,
  makeWrapper,
  writeText,
  jdk,
  gradle_7,
  git,
  perl,
  glew,
  xorg,
  libxkbcommon,
  libglvnd,
  zlib,
  buildFHSEnv,
  extraPkgs ? pkgs: [],
  extraLibs ? pkgs: [],
}: let
  # fake build to pre-download deps into fixed-output derivation
  pname = "sheepit-client";
  version = "7.23332.0";

  src = fetchFromGitLab {
    owner = "sheepitrenderfarm";
    repo = "client";
    rev = "v${version}";
    hash = "sha256-V+nDkUJAA+EBozG7D3NRapwuE68tUji5Tk7goro7ROY=";
  };

  # https://aur.archlinux.org/cgit/aur.git/tree/build.gradle.patch?h=sheepit-client-git
  patches = [
    ./build.gradle.patch
  ];

  deps = stdenv.mkDerivation {
    name = "${pname}-deps";
    inherit src version patches;

    nativeBuildInputs = [
      jdk
      git
      perl
      gradle_7
    ];

    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d);
      gradle --no-daemon --exclude-task generateVersionFile shadowJar
    '';

    # Mavenize dependency paths
    # e.g. org.codehaus.groovy/groovy/2.4.0/{hash}/groovy-2.4.0.jar -> org/codehaus/groovy/groovy/2.4.0/groovy-2.4.0.jar
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-a8X5YKh/GQU6bOF+SAoe572/GbZIQGgROslJo6aWsqc=";
  };

  # Point to our local deps repo
  gradleInit = writeText "init.gradle" ''
    logger.lifecycle 'Replacing Maven repositories with ${deps}...'
    gradle.projectsLoaded {
      rootProject.allprojects {
        buildscript {
          repositories {
            clear()
            maven { url '${deps}' }
          }
        }
        repositories {
          clear()
          maven { url '${deps}' }
        }
      }
    }
    settingsEvaluated { settings ->
      settings.pluginManagement {
        repositories {
          maven { url '${deps}' }
        }
      }
    }
  '';
in
  stdenv.mkDerivation rec {
    inherit pname version src patches;

    fhsenv = buildFHSEnv {
      name = "${pname}-fhs-env";
      runScript = "";

      # TODO Fix sheepit SIGTERM on SIGINT in bwrap

      targetPkgs = pkgs:
        with pkgs;
          [
            jdk
          ]
          ++ extraPkgs pkgs;

      multiPkgs = pkgs:
        with pkgs;
          [
            libglvnd
            xorg.libX11
            xorg.libXfixes
            xorg.libXi
            xorg.libXrender
            xorg.libXxf86vm
            xorg.libSM
            xorg.libICE
            libxkbcommon
            glew
            zlib
          ]
          ++ extraLibs pkgs;
    };

    nativeBuildInputs = [
      jdk
      git
      gradle_7
      makeWrapper
    ];

    preBuild = ''
      printf "${version}" > src/main/resources/VERSION
    '';

    buildPhase = ''
      runHook preBuild

      export GRADLE_USER_HOME=$(mktemp -d);
      gradle --offline --no-daemon --info -Dorg.gradle.java.home=${jdk}/lib/openjdk --exclude-task generateVersionFile --init-script ${gradleInit} shadowJar

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -pv $out/bin $out/share/java
      cp build/libs/sheepit-client-all.jar $out/share/java/${pname}.jar

      runHook postInstall
    '';

    postFixup = ''
      makeWrapper ${fhsenv}/bin/${pname}-fhs-env $out/bin/${pname} \
        --add-flags "${jdk}/bin/java -jar $out/share/java/${pname}.jar"
    '';

    meta = with lib; {
      # supernekonyannyan (an admin) from the Sheepit discord has
      # requested to clarify that this implementation is not officially
      # supported. Please make a issue in nixpkgs before asking sheepit.
      description = "A client for the Sheepit render farm.";
      homepage = "https://gitlab.com/sheepitrenderfarm/client/";
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      license = licenses.gpl2Only;
      maintainers = with maintainers; [hubble];
    };
  }
