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
        # Newest as of 2025-05-28
        rev = "0197eeddf3c21b01c714609584d9ed801ba630f0";
      in {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "thaytan";
          repo = "monado";
          inherit rev;
          hash = "sha256-o9JI2vCuDHEI6MNIWjbw7HGUBsnRQo58AUtDw1XUgw8=";
        };
        version = rev;

        patches =
          previousAttrs.patches
          ++ [
            (pkgs.fetchpatch {
              url = "https://aur.archlinux.org/cgit/aur.git/plain/010-monado-vulkan-headers1.4.310-fix.patch?h=monado";
              hash = "sha256-yydbH/7aVKE3HH4ecJ10dfcX0Wilm9jSFyF0zpMq/B0=";
            })
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
    U_PACING_COMP_MIN_TIME_MS = "10";
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
