{ config, lib, pkgs, hs-utils, ... }: 
let 

  port = 58284;
  name = "hsmn0";

  lighthouses = [
    {
      hostname = "alex-oracle-remote";
      ip = "100.86.87.1";
      route = ["alex.gulo.dev:${toString port}"];
    }
  ];

  relayHosts = {
    "alex-oracle-remote" = "100.86.87.1";
  };

  # Set number of routines based on thread count
  threads = {
    "remote" = 1;
    "lcluster" = 4;
    "Laptop" = 8;
    "picluster" = 2;
  };

  # Does any hostnames in lighthouses equal the current machine's hostname?
  isLighthouse = (builtins.any (x: x == config.networking.hostName) (map (x: x.hostname) lighthouses) );
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

    staticHostMap = lib.optionalAttrs (!isLighthouse) (lib.attrsets.mergeAttrsList (map (x: {
      ${x.ip} = x.route;
    }) lighthouses));

    lighthouses = lib.optionals (!isLighthouse) (map (x: x.ip) lighthouses);

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

      pki = {
        # blocklist is a list of certificate fingerprints that we will refuse to talk to
        blocklist = [];
      };
      
      routines = threads.${lib.last (lib.splitString "-" config.networking.hostName)};
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
          proto = "icmp";
        }
      ];
    };
  };
}