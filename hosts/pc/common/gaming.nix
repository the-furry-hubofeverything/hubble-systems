{pkgs, ...}: {
  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = [
    pkgs.protonup-ng
    pkgs.gamescope
  ];

  # VRChat firewall ports
  # TODO secure ports
  networking.firewall = {
    allowedTCPPorts = [80 443];
    allowedUDPPorts = [5055 5056 5058];
    allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27100;
      }
    ];
  };
}
