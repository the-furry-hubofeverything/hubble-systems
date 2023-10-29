{config, ...}: {
  users.users.hubble = {
    isNormalUser = true;
    description = "Hubble";
    extraGroups =
      ["networkmanager" "wheel"]
      ++ (
        if config.programs.wireshark.enable
        then ["wireshark"]
        else []
      );
  };

  users.motd = "🐾🐾🐾🐾";
}
