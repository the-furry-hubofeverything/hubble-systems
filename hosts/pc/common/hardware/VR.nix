{pkgs, config, ...}: let

in {
  services.wivrn = {
    enable = true;
    package = (pkgs.wivrn.override {
      cudaSupport = true;
    });
    steam = {
      enable = true;
      package = config.programs.steam.package;
      importOXRRuntimes = true;
    };
    highPriority = true;
    openFirewall = true;

  };
}
