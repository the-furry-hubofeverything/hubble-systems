{
  inputs,
  sharedModules,
  commonVMConfig,
  ...
}: let
  lclusterModules = sharedModules ++ [./common];
in {
  # TODO: Get impermanance either working or just remove it
  lcluster-common = {
    active = false;
    platform = "x86_64-linux";
    modules =
      lclusterModules
      ++ [
        commonVMConfig
      ];
  };

  titan-razer-lcluster = {
    platform = "x86_64-linux";
    active = true;
    modules =
      lclusterModules
      ++ [
        ./titan-razer-lcluster/configuration.nix
        inputs.hs-secrets.nixosModules.lcluster.titan
      ];
  };

  enterprise-asus-lcluster = {
    platform = "x86_64-linux";
    active = true;
    modules =
      lclusterModules
      ++ [
        ./enterprise-asus-lcluster/configuration.nix
        inputs.hs-secrets.nixosModules.lcluster.enterprise
      ];
  };
}
