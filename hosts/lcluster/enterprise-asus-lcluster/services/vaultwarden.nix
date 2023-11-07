{
  config,
  pkgs,
  ...
}: {
    assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${config.networking.hostName}.gulo.dev";
      message = "vaultwarden: vaultwarden depends on acme-nginx-rp.nix";
    }
    {
      assertion = config.services.blocky.enable && config.services.blocky.settings.customDNS.mapping ? "vw.gulo.dev";
      message = "vaultwarden: vw.gulo.dev is not configured in DNS";
    }
    {
      assertion = config.services.blocky.settings.customDNS.mapping."vw.gulo.dev" == config.services.blocky.settings.customDNS.mapping."${config.networking.hostName}.gulo.dev";
      message = "vaultwarden: DNS record incorrect, must be set to the correct machine";
    }
    {
      assertion = builtins.elem "tank" config.boot.zfs.extraPools;
      message = "vaultwarden: zfs pool 'tank' is not imported";
    }
  ];

  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SIGNUPS_ALLOWED = false;
      SHOW_PASSWORD_HINT = true;
      DOMAIN = "https://vw.gulo.dev";
    };
    backupDir = "/tank/data/vw-backup";
  };

  services.nginx.virtualHosts."vw.gulo.dev" = {
    useACMEHost = "gulo.dev";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    };
  };
}