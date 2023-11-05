{config, lib, ...}: {
  users.users.hubble = {
    isNormalUser = true;
    description = "Hubble";
    extraGroups =
      ["networkmanager" "wheel"]
      ++ lib.optionals config.programs.wireshark.enable ["wireshark"];
  };

  users.motd = "🐾🐾🐾🐾";
}
