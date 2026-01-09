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
    extraPackages = with pkgs; [
      gamescope
      gamescope-wsi
    ];
  };

  programs.gamescope = {
    enable = true;
  };

  security.pam.loginLimits = lib.mkForce [
    {
      domain = "users";
      item = "nofile";
      type = "hard";
      value = "524288";
    }
  ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
  };

  environment.systemPackages = [
    pkgs.protonup-qt
  ];
}
