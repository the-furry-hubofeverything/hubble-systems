{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
  ];

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
    platformOptimizations.enable = true;

    # WIP
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
    "fs.file-max" = 524288;
  };

  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  environment.systemPackages = [
    pkgs.protonup-qt

    (inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.star-citizen.override
    (prev: {
      location = "/run/media/hubble/Data/Games/star-citizen";
    }))
    pkgs.wineWowPackages.stagingFull
  ];
}
