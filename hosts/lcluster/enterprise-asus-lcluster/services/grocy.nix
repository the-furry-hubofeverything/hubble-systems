{
  config,
  pkgs,
  outputs,
  ...
}: {
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${config.networking.hostName}.gulo.dev";
      message = "grocy: grocy depends on acme-nginx-rp.nix";
    }
    {
      assertion = config.services.blocky.enable && config.services.blocky.settings.customDNS.mapping ? "grocy.gulo.dev";
      message = "grocy: grocy.gulo.dev is not configured in DNS";
    }
    {
      assertion = config.services.blocky.settings.customDNS.mapping."grocy.gulo.dev" == config.services.blocky.settings.customDNS.mapping."${config.networking.hostName}.gulo.dev";
      message = "grocy: DNS record incorrect, must be set to the correct machine";
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