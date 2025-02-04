{config, lib, ...}: let
  port = 61520;
in {
  assertions = [
    {
      assertion = config.services.nebula.networks ? "hsmn0";
      message = "monitoring: Nebula network must be set up";
    }
  ];

  services.prometheus.exporters.node = {
    inherit port;

    enable = true;
    enabledCollectors = [
      "logind"
      "systemd"
    ] ++ lib.optionals (lib.last (lib.splitString "-" config.networking.hostName) == "remote") [
      # we're doin router shenanigans, of course we're gonna do this
      "network_route"
    ];

    disabledCollectors = [
      "textfile"
    ];
    openFirewall = true;
    firewallFilter = "-i nebula.hsmn0 -p tcp -m tcp --dport ${toString port}";
  };

  services.nebula.networks."hsmn0".firewall.inbound = [
    {
      inherit port;
      group = "lcluster";
      proto = "tcp";
    }
  ];

}