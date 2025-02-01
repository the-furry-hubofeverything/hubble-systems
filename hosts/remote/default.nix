{
  inputs,
  sharedModules,
  commonVMConfig,
  ...
}: let
  remoteModules = sharedModules ++ [./common];
in {
  remote-common = {
    platform = "x86_64-linux";
    modules =
      remoteModules
      ++ [
        commonVMConfig
      ];
  };

  alex-oracle-remote = {
    platform = "aarch64-linux";
    modules =
      remoteModules
      ++ [
        ./alex-oracle-remote/configuration.nix
        inputs.hs-secrets.nixosModules.remote.alex
      ];
  };

  alan-google-remote = {
    platform = "x86_64-linux";
    modules =
      remoteModules
      ++ [
        ./alan-google-remote/configuration.nix
        inputs.hs-secrets.nixosModules.remote.alan
      ];
  };
}
