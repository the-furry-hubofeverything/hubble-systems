{ config, pkgs, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      dnsProvider = "porkbun";
      email = "hubblethewolverine@gmail.com";
      credentialsFile = "${pkgs.writeText "porkbun-creds" ''
        PORKBUN_API_KEY_FILE=${config.sops.secrets.porkbun-api-key.path}
        PORKBUN_SECRET_API_KEY_FILE=${config.sops.secrets.porkbun-api-sKey.path}
      ''}";
    };
  };
  
  sops.secrets.porkbun-api-key.owner = if config.security.acme.useRoot then "root" else "acme";
  sops.secrets.porkbun-api-key.group = config.security.acme.defaults.group;
  sops.secrets.porkbun-api-sKey.owner = if config.security.acme.useRoot then "root" else "acme";
  sops.secrets.porkbun-api-sKey.group = config.security.acme.defaults.group;

  services.nginx = {
    enable = true;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
    virtualHosts."${config.networking.hostName}.gulo.dev" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
    };
  };
}