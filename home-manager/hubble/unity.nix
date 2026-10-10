# Modfied original nix file by Laggron ala https://gist.github.com/nil-vr/09f6ebf470701d007553cf0de7c2c3ee?permalink_comment_id=6196632#gistcomment-6196632
{
  config,
  lib,
  pkgs,
  ...
}: let
  # corefonts/dejavu/liberation are already bundled in the fhsEnv on nixpkgs unstable
  # needs unzip for unity module installs
  unityhub = pkgs.unityhub.override {extraPkgs = p: [p.ipafont p.unzip];};

  fhsBin = "${unityhub.fhsEnv}/bin/unityhub-fhs-env";

  unityVersion = "2022.3.22f1";
  # Make sure the Editor is installed in the home folder!!!
  editorDir = "${config.home.homeDirectory}/UnityHub/${unityVersion}/Editor";

  wrapper = pkgs.writeShellScript "unity-fhs" ''
    real="${editorDir}/Unity.real"
    exec -a "$real" "${fhsBin}" "$real" "$@"
  '';
in {
  home.packages = [unityhub pkgs.alcom];

  home.activation.wrapUnityFhs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    editor="${editorDir}"
    if [ -x "$editor/Unity" ] && [ ! -e "$editor/Unity.real" ]; then
      $DRY_RUN_CMD mv "$editor/Unity" "$editor/Unity.real"
      $DRY_RUN_CMD install -m755 ${wrapper} "$editor/Unity"
    fi
  '';
}
