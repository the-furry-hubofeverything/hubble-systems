{ lib
, stdenv
, fetchFromGitLab
# , fetchurl
, makeWrapper
, addOpenGLRunpath
, writeText
, jdk
, gradle_7
, git
, perl
, glew
, xorg
, cudaPackages
}:

let   # fake build to pre-download deps into fixed-output derivation
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
in stdenv.mkDerivation rec {
  inherit pname version src patches;

  # src = fetchurl {
  #   url = "https://www.sheepit-renderfarm.com/media/applet/sheepit-client-${version}.jar";
  #   hash = "sha256-juojHct/mpgY0Kgp4WVGM/2/RelJ+4zmkF1qhJE1Bb8=";
  # };

  # dontUnpack = true;

  # TODO gradle is such a pain in the butt
  # buildInputs = [  ];
  nativeBuildInputs = [ 
    jdk 
    git 
    gradle_7
    glew
    xorg.libXrender
    xorg.libXfixes
    xorg.libXi
    xorg.libXxf86vm
    makeWrapper 
    cudaPackages.cudatoolkit
    cudaPackages.autoAddOpenGLRunpathHook 
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

    makeWrapper ${jdk}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/java/${pname}.jar"

    runHook postInstall
  '';

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.com/sheepitrenderfarm/client/";
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ hubble ];
  };
}
