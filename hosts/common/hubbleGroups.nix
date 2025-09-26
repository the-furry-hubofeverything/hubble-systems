{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  users.users.hubble = {
    isNormalUser = true;
    description = "Hubble";
    extraGroups =
      ["networkmanager" "wheel"]
      ++ lib.optionals config.programs.wireshark.enable ["wireshark"]
      ++ lib.optionals config.musnix.enable ["audio"]
      ++ lib.optionals config.services.displayManager.enable ["video"];
  };

  users.motd = "🐾🐾🐾🐾";
}
