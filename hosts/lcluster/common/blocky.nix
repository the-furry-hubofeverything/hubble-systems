{ config, ... }: {
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        # DNS over HTTPS support
        https = 44343;
      };

      upstream = {
        default = [
          # All DoH resolvers, which means this can act like a proxy for non-DoH capable apps
          "https://cloudflare-dns.com/dns-query"
          "https://dns.google/dns-query"
          "https://dns.quad9.net/dns-query"
          "https://anycast.uncensoreddns.org/dns-query"
        ];
      };

      startVerifyUpstream = true;

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
          # might change later
          "titan-razer-lcluster.gulo.dev" = "100.106.179.153";
          "enterprise-asus-lcluster.gulo.dev" = "100.106.28.233";
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
}