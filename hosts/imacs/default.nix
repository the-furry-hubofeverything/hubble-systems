{
  inputs,
  sharedModules,
  commonVMConfig,
  ...
}: let
  imacModules =
    sharedModules
    ++ [
      ./common
    ];
in {
  imac-common = {
    platform = "x86_64-linux";
    modules =
      imacModules
      ++ [
        commonVMConfig
      ];
  };

  ennos-imac = {
    platform = "x86_64-linux";
    modules =
      imacModules
      ++ [
        ./ennos-imac/configuration.nix
        inputs.hs-secrets.nixosModules.imac.ennos
      ];
  };

  lily-imac = {
    platform = "x86_64-linux";
    modules =
      imacModules
      ++ [
        ./lily-imac/configuration.nix
        inputs.hs-secrets.nixosModules.imac.lily
      ];
  };
}
