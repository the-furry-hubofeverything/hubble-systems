{
  inputs,
  outputs,
  sharedModules,
  hostId-common,
  ...
}: let
  piClusterModules = sharedModules ++ [./common];
in {
  picluster-common = {
    platform = "aarch64-linux";
    modules = piClusterModules ++ [
      hostId-common
    ];
  };

  brain-pi4-picluster = {
    platform = "aarch64-linux";
    modules =
      piClusterModules
      ++ [
        ./brain-pi4-picluster/configuration.nix
        inputs.hs-secrets.nixosModules.picluster.brain
      ];
  };
  pinky-pi3-piCluster = {
    platform = "aarch64-linux";
    modules =
      piClusterModules
      ++ [
        ./pinky-pi3-picluster/configuration.nix
        inputs.hs-secrets.nixosModules.picluster.pinky
      ];
  };
}