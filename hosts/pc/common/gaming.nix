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
    gamescopeSession = {
      enable = true;
      env = {
        PROTON_USE_NTSYNC = "1";
        DXVK_HDR = "1";
      };
      args = [
        "-w 2560"
        "-h 1440"
        "--enable-hdr"
        "--adaptive-sync"
        "--hdr-itm-enable" 
        "--hdr-itm-target-nits 600" 
        "--hdr-itm-sdr-nits 100" 
        "--hdr-sdr-content-nits 400"
        "-O DP-2"
      ];
    };
    extraPackages = with pkgs; [
      gamescope
      gamescope-wsi
    ];
  };

  services.udev.extraRules = ''
    # Disable DS4 touchpad acting as mouse
    # USB
    ATTRS{name}=="Sony Computer Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    # Bluetooth
    ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

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
