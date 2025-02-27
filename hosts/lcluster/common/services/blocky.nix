{
  config,
  lib,
  ...
}: let
  # custom DNS moved to porkbun
in {
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${lib.head (lib.splitString "-" config.networking.hostName)}.nebula.gulo.dev";
      message = "blocky: ${lib.head (lib.splitString "-" config.networking.hostName)}.nebula.gulo.dev is undefinied, this depends on acme-nginx-rp.nix";
    }
  ];

  services.blocky = {
    enable = true;
    settings = {
      ports = {
        # DNS over HTTPS support
        https = 44343;
        # DNS over TLS support
        tls = 853;
      };

      certFile = config.security.acme.certs."gulo.dev".directory + "/fullchain.pem";
      keyFile = config.security.acme.certs."gulo.dev".directory + "/key.pem";

      upstreams = {
        groups = {
          default = [
            # All DoH resolvers, which means this can act like a proxy for non-DoH capable apps
            "https://cloudflare-dns.com/dns-query"
            "https://dns.google/dns-query"
            "https://dns.quad9.net/dns-query"
            "https://anycast.uncensoreddns.org/dns-query"
          ];
        };
      };

      startVerifyUpstream = true;

      bootstrapDns = [
        {
          upstream = "https://dns.google/dns-query";
          ips = [
            "8.8.8.8"
            "8.8.4.4"
            "2001:4860:4860::8888"
            "2001:4860:4860::8844"
          ];
        }
        {
          upstream = "https://cloudflare-dns.com/dns-query";
          ips = [
            "104.16.248.249"
            "104.16.249.249"
            "2606:4700::6810:f9f9"
            "2606:4700::6810:f8f9"
          ];
        }
      ];

      blocking = {
        blackLists = {
          ads = [
            # Migrated from Pihole
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          ];
        };
        clientGroupsBlock = {
          default = [
            "ads"
          ];
        };
      };

      # I don't want to log your requests please
      log = {
        level = "warn";
        privacy = true;
      };
    };
  };

  # Reverse proxy for DoH
  services.nginx.virtualHosts."dns.gulo.dev" = {
    useACMEHost = "gulo.dev";
    forceSSL = true;
    # block path
    locations."/" = {
      return = "404";
    };

    locations."/dns-query" = {
      proxyPass = "https://127.0.0.1:44343";
      extraConfig =
        # required when the target is also TLS server with multiple hosts
        "proxy_ssl_server_name on;";
    };
  };

  systemd.services.blocky = {
    after = ["network-online.target"];
    before = ["nss-lookup.target"];
    wants = ["network-online.target" "nss-lookup.target"];

    serviceConfig = {
      restartSec = "500ms";
    };
  };

  systemd.services."blocky".serviceConfig.SupplementaryGroups =
    if config.security.acme.useRoot
    then ["root"]
    else ["acme"];

  networking = {
    # Allow DNS server access
    firewall = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [853];
    };

    nameservers = lib.mkForce [
      "127.0.0.1"
    ];
  };

  services.nebula.networks."hsmn0".firewall.inbound =
    lib.optionals config.services.nebula.networks."hsmn0".enable
    [
      {
        port = "53";
        proto = "udp";
        host = "any";
      }
      {
        port = "853";
        proto = "tcp";
        host = "any";
      }
    ];
}
