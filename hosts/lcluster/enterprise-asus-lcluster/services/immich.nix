{
  config,
  lib,
  pkgs,
  ...
}: {
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${lib.head (lib.splitString "-" config.networking.hostName)}.nebula.gulo.dev";
      message = "grocy: grocy depends on acme-nginx-rp.nix";
    }
  ];

  services.immich = {
    enable = true;
    port = 2283;
    package = pkgs.unstable.immich;
    environment = {
      "CPU_CORES" = "4";
    };
    mediaLocation = "/tank/large/immich";
  };

  services.immich.accelerationDevices = [
    "/dev/dri/by-path/pci-0000:01:00.0-render"
  ];

  users.users.immich.extraGroups = ["video" "render"];

  services.nginx.virtualHosts."immich.gulo.dev" = {
    useACMEHost = "gulo.dev";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };
}
