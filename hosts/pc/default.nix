{
  inputs,
  sharedModules,
  commonVMConfig,
  ...
}: let
  pcModules =
    sharedModules
    ++ [
      ./common
      inputs.niri-flake.nixosModules.niri
    ];
in {
  pc-common = {
    platform = "x86_64-linux";
    active = false;
    modules =
      pcModules
      ++ [
        commonVMConfig
      ];
  };

  Gulo-Laptop = {
    platform = "x86_64-linux";
    active = true;
    modules =
      pcModules
      ++ [
        ./gulo-laptop/configuration.nix
        inputs.hs-secrets.nixosModules.pc.Gulo-Laptop
      ];
  };
}
