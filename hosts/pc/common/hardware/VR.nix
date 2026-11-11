{
  pkgs,
  config,
  inputs,
  ...
}: let
  xrizer-patched = pkgs.xrizer.overrideAttrs {
    name = "xrizer-patched";
    patches = [
      (pkgs.fetchurl {
        name = "frame.patch";
        url = "https://patch-diff.githubusercontent.com/raw/Supreeeme/xrizer/pull/464.patch";
        hash = "sha256-Szq+iRoZE3F5mXoAHclVBfpPqR1vzwz5qpjR9goO4oo=";
      })
    ];
  };
in {
  services.wivrn = {
    enable = true;
    # Don't use NVENC - not well supported
    package = (
      let
        version = "4d782f737053ea32d54524cf817c2a483565ddbb";
      in
        (pkgs.wivrn.overrideAttrs  (f: p: {
          inherit version;
          src = pkgs.applyPatches {
            src = pkgs.fetchFromGitHub {
              owner = "wivrn";
              repo = "wivrn";
              rev = version;
              hash = "sha256-kTkdgpGVyamAspssfersLsPEWyb6IUis4hXfBDsqX/o=";
            };
            patches = [
              ./caszuu-supersampling-support.patch
              ./add-conforming-ht-input.patch
            ];

            postPatch = ''
              cp ${./0010-a-shaders-target-spirv-1.3-Vulkan-1.1.patch} patches/monado/
              cp ${./0011-a-shaders-add-per-layer-supersampling.patch} patches/monado/
            '';
          };
        })).override {
          ovrCompatSearchPaths = "${xrizer-patched}/lib/xrizer:${pkgs.xrizer}/lib/xrizer:${pkgs.opencomposite}/lib/opencomposite";
        }
    );
    monadoEnvironment = {
      U_PACING_APP_USE_MIN_FRAME_PERIOD = "1";
      # little over 90hz
      U_PACING_COMP_MIN_TIME_MS = "10";

      XRT_COMPOSITOR_USE_PRESENT_WAIT = "1";
      U_PACING_COMP_TIME_FRACTION_PERCENT = "90";
      U_PACING_APP_IMMEDIATE_WAIT_FRAME_RETURN_BELOW_REFRESH = "1";

      XRT_COMPOSITOR_FORCE_WAYLAND_DIRECT = "1";
    };
    steam = {
      enable = true;
      package = config.programs.steam.package;
      importOXRRuntimes = true;
    };
    highPriority = true;
    openFirewall = true;
    config = {
      enable = true;
      json = {
        # left eye; right eye; transparency
        encoder = [
          {
            encoder = "vulkan";
            codec = "h265";
            device = "/dev/dri/renderD129";
          }
          {
            encoder = "vulkan";
            codec = "h265";
            device = "/dev/dri/renderD129";
          }
          {
            encoder = "vulkan";
            codec = "h265";
          }
        ];
      };
    };
  };

  services.ananicy = {
    extraRules = [
      {
        name = "monado";
        nice = "-20";
      }
    ];
  };

  environment.systemPackages = [
    pkgs.wayvr
    pkgs.oscavmgr
  ];

  # Babble Face tracking for Steam Frame
  networking.firewall.allowedUDPPorts = [6767];
}
