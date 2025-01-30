{
  config,
  lib,
  ...
}: {
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${lib.head (lib.splitString "-" config.networking.hostName)}.nebula.gulo.dev";
      message = "grocy: grocy depends on acme-nginx-rp.nix";
    }
  ];

  services.grocy = {
    enable = true;
    hostName = "grocy.gulo.dev";
    dataDir = "/persist/grocy";
    settings = {
      currency = "CAD";
      culture = "en";
      calendar.firstDayOfWeek = 0;
    };

    # We want to define our own certs
    nginx.enableSSL = false;
  };

  services.nginx.virtualHosts."grocy.gulo.dev" = {
    useACMEHost = "gulo.dev";
    forceSSL = true;
  };
}
