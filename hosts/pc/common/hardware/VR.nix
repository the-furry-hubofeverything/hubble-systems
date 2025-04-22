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
  };

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    VIT_SYSTEM_LIBRARY_PATH = basalt + "/lib/libbasalt.so";
  };
}
