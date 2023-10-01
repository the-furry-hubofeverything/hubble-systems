{
  inputs,
  outputs,
}: let
  # Machine categories
  machineType = import ./machineType {inherit inputs outputs;};

  nixos-hardware = inputs.hardware.nixosModules;
in {
  # TODO change hostname
  hostname = {
    platform = "aarch64-linux";
    modules =
      # Common machineType modules
      machineType.modules
      ++ [
        # Configuration.nix for machine
        ./machineType/hostname/configuration.nix
      ];
  };
}
