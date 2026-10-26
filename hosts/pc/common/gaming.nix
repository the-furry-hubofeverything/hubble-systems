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
    enableRenice = true;
    settings = {
      general.renice = 10;

      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1;
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  environment.variables = {
    GAMEMODERUNEXEC = "env PIPEWIRE_LATENCY=128/48000 PROTON_USE_NTSYNC=1 __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only";
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        # steamvr uses nvidia gpu
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };

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

    extraCompatPackages = with pkgs; [
      proton-ge-rtsp-bin
    ];
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server

    protontricks.enable = true;

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
        "-W 2560"
        "-H 1440"
        "-e"
        "-r 240"
        "--immediate-flips"
        "--hdr-enabled"
        "--adaptive-sync"
        "--hdr-itm-enable"
        "--hdr-itm-target-nits 600"
        "--hdr-itm-sdr-nits 100"
        "--hdr-sdr-content-nits 400"
        "-O DP-1"
        "--prefer-vk-device 10de:2191"
      ];
      steamArgs = [
        "-steamos3"
        "-pipewire-dmabuf"
      ];
    };
  };

  # Steam frame adapter regulatory setting
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=CA
  '';

  services.udev.extraRules = ''
    # Skip if a remove
    ACTION=="remove", GOTO="xrhardware_end"

    # Microsoft Windows MR Controller - Bluetooth
    KERNELS=="0005:045E:065B.*", TAG+="uaccess", ENV{ID_xrhardware}="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"


    # Microsoft Windows MR Controller - Bluetooth
    KERNELS=="0005:045E:065D.*", TAG+="uaccess", ENV{ID_xrhardware}="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"


    # Microsoft Windows MR Controller (Reverb G2) - Bluetooth
    KERNELS=="0005:045E:066A.*", TAG+="uaccess", ENV{ID_xrhardware}="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"


    # Microsoft HoloLens Sensors - USB
    ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0659", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Samsung Odyssey sensors - USB
    ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="7310", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Samsung Odyssey+ sensors - USB
    ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="7312", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # HP VR1000 - USB
    ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0367", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # HP Reverb G1 - USB
    ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0c6a", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # HP Reverb G2 - USB
    ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0580", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # HP Reverb G2 Omnicept - USB
    ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0680", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Lenovo QHMD/Explorer - USB
    ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="b801", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Lenovo QHMD/Explorer No Controllers - USB
    ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="b800", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Acer AH100 QHMD - USB
    ATTRS{idVendor}=="0502", ATTRS{idProduct}=="b0d5", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Acer AH101 QHMD - USB
    ATTRS{idVendor}=="0502", ATTRS{idProduct}=="b0d6", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Dell Visor VR118 - USB
    ATTRS{idVendor}=="413c", ATTRS{idProduct}=="b0d5", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Medion Erazer X1000 - USB
    ATTRS{idVendor}=="0408", ATTRS{idProduct}=="b5d5", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Cypress Semiconductor Corp. (Various WMR) - USB
    ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="6504", TAG+="uaccess", ENV{ID_xrhardware}="1"


    # Exit if we didn't find one
    ENV{ID_xrhardware}!="1", GOTO="xrhardware_end"

    # XR devices with serial ports aren't modems, modem-manager
    ENV{ID_xrhardware_USBSERIAL_NAME}!="", SUBSYSTEM=="usb", ENV{ID_MM_DEVICE_IGNORE}="1"

    # Make friendly symlinks for XR USB-Serial devices.
    ENV{ID_xrhardware_USBSERIAL_NAME}!="", SUBSYSTEM=="tty", SYMLINK+="ttyUSB.$env{ID_xrhardware_USBSERIAL_NAME}"

    LABEL="xrhardware_end"

    # Disable DS4 touchpad acting as mouse
    # USB
    ATTRS{name}=="Sony Computer Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    # Bluetooth
    ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  programs.gamescope = {
    enable = true;
    env = {
      # use nvidia GPU for compositor
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
    };
    # enableWsi = true;
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
    patchedBwrap
  ];
}
