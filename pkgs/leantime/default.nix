{
  php,
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}: let
  version = "v3.9.5";
  src = fetchFromGitHub {
    owner = "Leantime";
    repo = "leantime";
    tag = version;
    hash = "sha256-5tlSnrQgb+kW+LA88nzEN+eggwRtJzBi1tUSOl9Ol9w=";
  };
  nodePkg = buildNpmPackage {
    pname = "leantime-assets";
    inherit version;
    inherit src;
    npmDepsHash = "sha256-AAkt9vquK/NMWzfYGITKMsbDgFCVCeBewzyr181kP0Y=";
    npmFlags = [
      "--legacy-peer-deps"
    ];
    dontNpmBuild = true;
    buildPhase = ''
       export PATH="$PWD/node_modules/.bin:$PATH"

      ./node_modules/.bin/mix
    '';
    installPhase = ''
      mkdir -p $out/public
      cp -r public/* $out/public
    '';
  };
in
php.buildComposerProject2 (finalAttrs: {
  pname = "leantime";
  version = version;
  inherit src;

    patches = [
      ./storage.patch
      ./userfiles.patch
    ];

    vendorHash = "sha256-a6nmiflEBcQkALdPyHyGPUu4IsR8u0YDjtI1uovTaPA=";

  postInstall = ''
    rm -rf $out/share/php/leantime/public
    cp -r ${nodePkg}/public $out/share/php/leantime
  '';

  meta = {
    description = "An open source project management system";
    license = lib.licenses.agpl3Only;
    homepage = "https://leantime.io";
    maintainers = with lib.maintainers; [ jordycoding ];
  };
})
