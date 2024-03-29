{ config, pkgs, lib, ... }: {
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
      extraDomainNames = [ "*.gulo.dev" ];
      dnsPropagationCheck = true;
    };
  };
  
  sops.secrets.porkbun-api-key.owner = if config.security.acme.useRoot then "root" else "acme";
  sops.secrets.porkbun-api-key.group = config.security.acme.defaults.group;
  sops.secrets.porkbun-api-sKey.owner = if config.security.acme.useRoot then "root" else "acme";
  sops.secrets.porkbun-api-sKey.group = config.security.acme.defaults.group;


  users.users.nginx.extraGroups = [ "acme" ];
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

  # Allow Netbird Access
  networking.firewall.interfaces."wt0".allowedTCPPorts = lib.optionals config.services.netbird.enable [ 443 ];
}