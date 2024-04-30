{
  config,
  hs-utils,
  pkgs,
  lib,
  ...
}: {
  assertions = [
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "acme-nginx-rp: defaultSopsFile not empty, cannot continue";
    }
    {
      assertion = !hs-utils.sops.isDefault config.sops "porkbun-api-key";
      message = "acme-nginx-rp: Porkbun API key not defined";
    }
    {
      assertion = !hs-utils.sops.isDefault config.sops "porkbun-api-sKey";
      message = "acme-nginx-rp: Porkbun secret key not defined";
    }
    {
      assertion = config.services.nebula.networks ? "hsmn0";
      messages = "acme-nginx-rp: nebula network not defined, cannot continue.";
    }
    {
      assertion = config.services.nebula.networks."hsmn0".enable;
      messages = "acme-nginx-rp: nebula network not enabled, cannot continue.";
    }
  ];

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

    certs."gulo.dev" = {
      domain = "gulo.dev";
      extraDomainNames = ["*.gulo.dev"];
      dnsPropagationCheck = true;
    };
  };

  sops.secrets.porkbun-api-key.owner =
    if config.security.acme.useRoot
    then "root"
    else "acme";
  sops.secrets.porkbun-api-key.group = config.security.acme.defaults.group;
  sops.secrets.porkbun-api-sKey.owner =
    if config.security.acme.useRoot
    then "root"
    else "acme";
  sops.secrets.porkbun-api-sKey.group = config.security.acme.defaults.group;

  users.users.nginx.extraGroups = ["acme"];
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

  networking.firewall.interfaces."nebula.hsmn0".allowedTCPPorts = [443];
  services.nebula.networks."hsmn0".firewall.inbound = lib.optionals config.services.nebula.networks."hsmn0".enable [
    {
      port = "443";
      proto = "tcp";
      host = "any";
    }
  ];
}
