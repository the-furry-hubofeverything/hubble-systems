{
  inputs,
  outputs,
}: let
  # Machine categories
  machineType = import ./machineType {inherit inputs outputs;};

  sharedModules = {
    machineType = [
      # Insert common modules for machine type here
    ];
  };

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
