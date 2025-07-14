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
        rev = "467166935eea0183a8c8f5884c4ecd20c0eeacfb";
      in {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "thaytan";
          repo = "monado";
          inherit rev;
          hash = "sha256-IKO/bhUsISmRb3k+wAEscuTUXDyrzyVYQG1eJkLCIUI=";
        };
        version = rev;

        patches =
          previousAttrs.patches
          ++ [
            (
              pkgs.fetchpatch {
                url = "https://aur.archlinux.org/cgit/aur.git/plain/010-monado-vulkan-headers1.4.310-fix.patch?h=monado";
                hash = "sha256-yydbH/7aVKE3HH4ecJ10dfcX0Wilm9jSFyF0zpMq/B0=";
              }
            )

            # enables XRT_COMPOSITOR_USE_PRESENT_WAIT
            (
              pkgs.fetchpatch {
                url = "https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2490.diff";
                hash = "sha256-x3eJVvgt/5BPI5XezKykf3bejMNbeZRzI903eP6TsLw=";
              }
            )
            (
              pkgs.fetchpatch {
                url = "https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2452.patch";
                hash = "sha256-WXqqgNns+GyuME+TttNzubQJtXtxUVotkZ4VYPQrerQ=";
              }
            )
            (
              pkgs.fetchpatch {
                url = "https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2486.patch";
                hash = "sha256-RxiAN0v14sKGC5ZKEgWVvs5adl8DyBeSZ2HbynmpbQI=";
              }
            )

            (
              pkgs.fetchpatch {
                url = "https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2512.patch";
                hash = "sha256-z4sBJxvXwP76MPYQTvrdYb8K5DHwosfBmPdmg5Pn6Gs=";
              }
            )
            (
              pkgs.fetchpatch {
                url = "https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2515.patch";
                hash = "sha256-t5M6kEtwGRTHa6YbM8w4d5pLygLZQwy9YFWcfEwOhBQ=";
              }
            )
            (
              pkgs.fetchpatch {
                url = "https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2502.patch";
                hash = "sha256-y6/zzFpGcYvkzF7LW49EEMS8YIP7GKXAWqQc0dDnaFE=";
              }
            )
          ];
      }
    );
    defaultRuntime = true;
    highPriority = true;
  };

  # Some settings for the HP Reverb G2
  systemd.user.services."monado".environment = {
    XRT_COMPOSITOR_FORCE_NVIDIA_DISPLAY = "HP Inc.";
    XRT_COMPOSITOR_FORCE_NVIDIA = "1";
    XRT_COMPOSITOR_FORCE_WAYLAND_DIRECT = "true";
    XRT_COMPOSITOR_USE_PRESENT_WAIT = "1";
    U_PACING_COMP_MIN_TIME_MS = "15";
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
