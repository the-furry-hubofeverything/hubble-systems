{
  pkgs,
  config,
  ...
}: let
in {
  services.wivrn = {
    enable = true;
    # Don't use NVENC - not well supported
    package = pkgs.wivrn;
    steam = {
      enable = true;
      package = config.programs.steam.package;
      importOXRRuntimes = true;
    };
    highPriority = true;
    openFirewall = true;
  };

  environment.systemPackages = [ 
    pkgs.wayvr
    pkgs.oscavmgr
  ];

}
