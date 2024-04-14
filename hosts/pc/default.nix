{
  inputs,
  outputs,
  sharedModules,
  hostId-common,
  ...
}: let 
  pcModules = sharedModules ++ [./common];
in {
  pc-common = {
    platform = "x86_64-linux";
    modules = pcModules ++ [
      hostId-common
    ];
  };

  Gulo-Laptop = {
    platform = "x86_64-linux";
    modules =
      pcModules
      ++ [
        ./gulo-laptop/configuration.nix
        inputs.hs-secrets.nixosModules.pc.Gulo-Laptop
      ];
  };
}