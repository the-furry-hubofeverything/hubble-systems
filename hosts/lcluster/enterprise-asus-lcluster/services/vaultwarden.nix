{
  config,
  lib,
  ...
}: {
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${lib.head (lib.splitString "-" config.networking.hostName)}.nebula.gulo.dev";
      message = "vaultwarden: vaultwarden depends on acme-nginx-rp.nix";
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
