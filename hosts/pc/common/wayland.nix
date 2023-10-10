{pkgs, ...}: {
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Blender (Steam version) Wayland support
  programs.steam.package = pkgs.steam.override {
    extraLibraries = p:
      with p; [
        libdecor
      ];
  };
}
