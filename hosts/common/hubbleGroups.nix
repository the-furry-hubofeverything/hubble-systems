{ options, ... }: {
  users.users.hubble = {
    isNormalUser = true;
    description = "Hubble";
    extraGroups = ["networkmanager"  "wheel" ] + (if options.programs.wireshark.enable then [ "wireshark" ] else []);
  };
}