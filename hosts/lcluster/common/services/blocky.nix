{ config, lib, ... }: 
let 
  ips = {
    # might change later
    titan-razer-lcluster = "100.106.179.153";
    enterprise-asus-lcluster = "100.106.28.233";
  };
in 
{
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${config.networking.hostName}.gulo.dev";
      message = "blocky: ${config.networking.hostName}.gulo.dev is undefinied, this depends on acme-nginx-rp.nix";
    }
  ];

  services.blocky = {
    enable = true;
    settings = {
      ports = {
        # DNS over HTTPS support
        https = 44343;
      };

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

      # TODO blocky service seems to start before network devices do 
      # startVerifyUpstream = true;

      bootstrapDns = [
        {
          upstream = "https://dns.google/dns-query";
          ips = [
            "8.8.8.8"
            "8.8.4.4"
          ];
        }
        {
          upstream = "https://cloudflare-dns.com/dns-query";
          ips = [
            "104.16.248.249"
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

      customDNS = {
        mapping = {
          "titan-razer-lcluster.gulo.dev" = ips.titan-razer-lcluster;
          "enterprise-asus-lcluster.gulo.dev" = ips.enterprise-asus-lcluster;

          # Services
          "grocy.gulo.dev" = ips.enterprise-asus-lcluster;
          "vw.gulo.dev" = ips.enterprise-asus-lcluster;
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
  services.nginx.virtualHosts."${config.networking.hostName}.gulo.dev" = {
    locations."/dns-query" = {
      proxyPass = "https://127.0.0.1:44343";
      extraConfig =
        # required when the target is also TLS server with multiple hosts
        "proxy_ssl_server_name on;";
    };
  };

  # Allow DNS server access 
  networking.firewall = {
    allowedUDPPorts = [ 53 ];
  };
}