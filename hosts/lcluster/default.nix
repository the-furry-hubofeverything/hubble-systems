{
  inputs,
  outputs,
  sharedModules,
  hostId-common,
  ...
}: let
  lclusterModules = sharedModules ++ [./common];
in {
  # TODO: Get impermanance either working or just remove it
  lcluster-common = {
    platform = "x86_64-linux";
    modules =
      lclusterModules
      ++ [
        hostId-common
      ];
  };

  titan-razer-lcluster = {
    platform = "x86_64-linux";
    modules =
      lclusterModules
      ++ [
        ./titan-razer-lcluster/configuration.nix
        inputs.hs-secrets.nixosModules.lcluster.titan
      ];
  };

  enterprise-asus-lcluster = {
    platform = "x86_64-linux";
    modules =
      lclusterModules
      ++ [
        ./enterprise-asus-lcluster/configuration.nix
        inputs.hs-secrets.nixosModules.lcluster.enterprise
      ];
  };
}
