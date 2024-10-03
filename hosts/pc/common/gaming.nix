{
  pkgs,
  lib,
  ...
}: {
  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  security.pam.loginLimits = lib.mkForce [
    {
      domain = "users";
      item = "nofile";
      type = "hard";
      value = "524288";
    }
  ];

  environment.systemPackages = [
    pkgs.protonup-ng
    pkgs.gamescope
  ];
}
