{
  pkgs,
  lib,
  inputs,
  ...
}: let
  patchedBwrap = pkgs.bubblewrap.overrideAttrs (o: {
    patches =
      (o.patches or [])
      ++ [
        ./bwrap.patch
      ];
  });
in {
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
    inputs.nix-citizen.nixosModules.default
  ];

  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraLibraries = p:
        with p; [
          libdecor
        ];
      buildFHSEnv = args: ((pkgs.buildFHSEnv.override {
          bubblewrap = patchedBwrap;
        }) (args
          // {
            extraBwrapArgs = (args.extraBwrapArgs or []) ++ ["--cap-add ALL"];
          }));
    };
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

  security.pam.loginLimits = lib.mkBefore [
    {
      domain = "users";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
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
    substituters = [
      "https://nix-gaming.cachix.org"
      "https://nix-citizen.cachix.org"
    ];
    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    ];
  };

  programs.rsi-launcher = {
    # Enables the star citizen module
    enable = true;
    location = "/run/media/hubble/Data/Games/star-citizen";
  };

  environment.systemPackages = [
    pkgs.protonup-qt
    pkgs.wineWow64Packages.stagingFull
  ];
}
