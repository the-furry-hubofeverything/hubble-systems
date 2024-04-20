{ config, lib, pkgs, hs-utils, ... }: 
let 

  port = 58284;
  name = "hsmn0";

  lighthouse = {
    hostname = "alex-oracle-remote";
    ip = "100.86.87.1";
    route = ["alex.gulo.dev:${toString port}"];
  };

  relayHosts = {
    "alex-oracle-remote" = "100.86.87.1";
  };

  isLighthouse = (config.networking.hostName == lighthouse.hostname);
  owner = config.systemd.services."nebula@${name}".serviceConfig.User;
  group = config.systemd.services."nebula@${name}".serviceConfig.Group;
in 
{
  assertions = [
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "nebula: defaultSopsFile not empty, cannot continue";
    }
  ];

  sops.secrets = {
    nebulaCACert = {
      inherit owner group;
      mode = "440";
    };
    nebulaCert = {
      inherit owner group;
      mode = "400";
    };
    nebulaKey = {
      inherit owner group;
      mode = "400";
    };
  };

  services.nebula.networks."${name}" = {
    enable = true;

    # Lighthouse related config
    inherit isLighthouse;

    staticHostMap = lib.optionalAttrs (!isLighthouse) {
      "${lighthouse.ip}" = lighthouse.route;
    };

    lighthouses = lib.optionals (!isLighthouse) [lighthouse.ip];

    listen = {
      inherit port;
    };

    ca = hs-utils.sops.mkWarning config.sops "nebulaCACert" "nebula: CA cert secret not defined, using placeholder" ./ca.crt;  
    cert = hs-utils.sops.mkWarning config.sops "nebulaCert" "nebula: cert secret not defined, using placeholder" ./test.crt;
    key = hs-utils.sops.mkWarning config.sops "nebulaKey" "nebula: key secret not defined, using placeholder" ./test.key;

    settings = {
      punchy = {
        punch = true;
        respond = true;
      };
      cipher = "chachapoly";
    };

    isRelay = relayHosts ? config.networking.hostName;

    relays = lib.attrValues relayHosts;

    firewall = {
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];

      inbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
    };
  };
}