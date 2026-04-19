{pkgs, ...}: let
  basalt = pkgs.basalt-monado.overrideAttrs (final: prev: {
    cmakeFlags =
      prev.cmakeFlags
      ++ ["-DCUDA_TOOLKIT_ROOT_DIR=${pkgs.cudaPackages.cudatoolkit}"];
  });
in {
  environment.systemPackages = with pkgs;
    [
      opencomposite
    ]
    ++ [
      basalt
    ];

  services.monado = {
    enable = true;
    package = pkgs.monado.overrideAttrs (
      finalAttrs: previousAttrs: let
        # Newest as of 2025-07-10
        rev = "d77f2f157c1d668696f05f12e4b1220dd064674a";
      in {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "thaytan";
          repo = "monado";
          inherit rev;
          hash = "";
        };
        version = rev;
      }
    );
    defaultRuntime = true;
    highPriority = true;
  };

  # Some settings for the HP Reverb G2
  systemd.user.services."monado".environment = {
    XRT_COMPOSITOR_FORCE_NVIDIA_DISPLAY = "HP Inc.";
    XRT_COMPOSITOR_FORCE_NVIDIA = "1";
    XRT_COMPOSITOR_FORCE_WAYLAND_DIRECT = "1";
    
    XRT_COMPOSITOR_USE_PRESENT_WAIT = "1";
    U_PACING_COMP_TIME_FRACTION_PRECENT = "90";
    DISPLAY = ":0";

    # 4320x2160@60.00
    # Full refresh rate causes some issues rn
    XRT_COMPOSITOR_DESIRED_MODE = "2";

    WMR_HANDTRACKING = "0";

    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    VIT_SYSTEM_LIBRARY_PATH = basalt + "/lib/libbasalt.so";
  };
}
