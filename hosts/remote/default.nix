{
  inputs,
  outputs,
  sharedModules,
  hostId-common,
  ...
}: let
  remoteModules = sharedModules ++ [./common];
in {
  remote-common = {
    platform = "x86_64-linux";
    modules = remoteModules ++ [
      hostId-common
    ];
  };

  alex-oracle-remote = {
    platform = "x86_64-linux";
    modules =
      remoteModules
      ++ [
        ./alex-oracle-remote/configuration.nix
        inputs.hs-secrets.nixosModules.remote.alex
      ];
  };
}