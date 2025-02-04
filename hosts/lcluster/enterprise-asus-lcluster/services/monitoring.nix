{config, ...}: {
  assertions = [
    {
      assertion = config.services.prometheus.exporters.node.enable;
      message = "monitoring: must have exporter nodes in hosts/common";
    }
  ];

  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "hubbleSystems_nodes";
        static_configs = [
          {
            targets = map (x: x + ":${toString config.services.prometheus.exporters.node.port}") [
              "alex.nebula.gulo.dev"
              "alan.nebula.gulo.dev"
            ];
            labels = {
              group = "remote";
            };
          }
          {
            targets = map (x: x + ":${toString config.services.prometheus.exporters.node.port}") [
              "enterprise.nebula.gulo.dev"
              "titan.nebula.gulo.dev"
            ];
            labels = {
              group = "lcluster";
            };
          }
          {
            targets = map (x: x + ":${toString config.services.prometheus.exporters.node.port}") [
              "gulo-laptop.nebula.gulo.dev"
            ];
            labels = {
              group = "pc";
            };
          }
          {
            targets = map (x: x + ":${toString config.services.prometheus.exporters.node.port}") [
              "brain.nebula.gulo.dev"
              # "100.86.30.2"
            ];
            labels = {
              group = "picluster";
            };
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.gulo.dev";
      };

      # Prevents Grafana from phoning home
      analytics.reporting_enabled = false;
    };
  };

  services.nginx.virtualHosts."grafana.gulo.dev" = {
    forceSSL = true;
    useACMEHost = "gulo.dev";
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
