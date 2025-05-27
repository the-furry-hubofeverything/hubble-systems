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
    package = pkgs.monado;
    defaultRuntime = true;
    highPriority = true;
  };

  # Some settings for the HP Reverb G2
  systemd.user.services."monado".environment = {
    XRT_COMPOSITOR_FORCE_NVIDIA_DISPLAY = "HP Inc.";
    XRT_COMPOSITOR_FORCE_WAYLAND_DIRECT = "true";
    DISPLAY = ":0";
    U_PACING_COMP_MIN_TIME_MS = "16";

    # 4320x2160@60.00
    # Full refresh rate causes some issues rn
    XRT_COMPOSITOR_DESIRED_MODE = "2";

    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    VIT_SYSTEM_LIBRARY_PATH = basalt + "/lib/libbasalt.so";
  };
}
