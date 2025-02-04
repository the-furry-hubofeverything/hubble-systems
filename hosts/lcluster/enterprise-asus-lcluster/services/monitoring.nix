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
}
