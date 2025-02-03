{
  inputs,
  config,
  lib,
  hs-utils,
  pkgs,
  ...
}: let
  port = 58284;
  name = "hsmn0";

  lighthouses = {
    "alex-oracle-remote" = {
      ip = "100.86.87.1";
      route = ["129.153.99.90"];
      publicInterface = "enp0s6";
    };
    "alan-google-remote" = {
      ip = "100.86.87.2";
      route = ["35.209.133.46"];
      publicInterface = "eth0";
    };
  };

  # publicServices - For forwarding services from lighthouses to services on the network.

  # WORKAROUND - UDP is disabled, since the firewall option asserts only lists of ports, not an empty one.
  #    Uncomment the "networking.firewall.allowedUDPPorts" line below.
  publicServices = {
    # Don't forget to also port rule on nebula and the cloud firewall!!

    # minecraft servers on Titan
    "minecraft-smp" = {
      sourcePort = 25565;

      destination = "100.86.28.2";
      destinationPort = 25565;
      proto = "tcp";
      blocklist = true;
    };

    # Git server on Enterprise
    "git" = {
      sourcePort = 37084;

      destination = "100.86.28.1";
      destinationPort = 22;
      proto = "tcp";
      blocklist = false;
    };
  };

  relayHosts = {
    "alex-oracle-remote" = "100.86.87.1";
    "alan-google-remote" = "100.86.87.2";
    "brain-pi4-picluster" = "100.86.30.1";
  };

  # Set number of routines based on thread count
  threads = {
    "remote" = 1;
    "lcluster" = 4;
    "Laptop" = 8;
    "picluster" = 2;
  };

  hostGroup = lib.last (lib.splitString "-" config.networking.hostName);

  # Does any hostnames in lighthouses equal the current machine's hostname?
  isLighthouse = builtins.hasAttr config.networking.hostName lighthouses;
  isRelay = relayHosts ? ${config.networking.hostName};

  owner = config.systemd.services."nebula@${name}".serviceConfig.User;
  group = config.systemd.services."nebula@${name}".serviceConfig.Group;
in {
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

  networking.nameservers = lib.optionals (hostGroup != "remote" && !config.services.blocky.enable) [
    "100.86.28.1"
    "100.86.28.2"
  ];

  services.resolved = lib.optionalAttrs (hostGroup != "remote" && !config.services.blocky.enable) {
    enable = true;
    dnsovertls = "opportunistic";
  };

  # Logic for public services. Deployed on any machine in the remote host group
  networking.nat = lib.optionalAttrs (hostGroup == "remote") {
    enable = true;
    internalInterfaces = [("nebula." + name)];
    externalInterface = lighthouses.${config.networking.hostName}.publicInterface;
    # Port forwarding doesn't work without manually setting the routing in here.
    # Also sets up vps-ranges
    extraCommands = lib.concatLines (
      [
        "${pkgs.ipset}/bin/ipset flush || true"
        "${pkgs.ipset}/bin/ipset restore < /etc/ipset.conf"
      ]
      ++ lib.mapAttrsToList (
        _: x:
          ''
            iptables -t nat -A POSTROUTING -d ${x.destination} -p ${x.proto} -m ${x.proto} --dport ${toString x.destinationPort} -j MASQUERADE
          ''
          + lib.optionalString (x.blocklist) ''
            iptables -I FORWARD 1 -p ${x.proto} -m set --dport ${toString x.destinationPort} --match-set vps-ranges src -j DROP
          ''
      )
      publicServices
    );

    extraStopCommands = lib.concatLines (
      lib.mapAttrsToList (
        _: x:
          ''
            iptables -t nat -D POSTROUTING -d ${x.destination} -p ${x.proto} -m ${x.proto} --dport ${toString x.destinationPort} -j MASQUERADE || true
          ''
          + lib.optionalString (x.blocklist) ''
            iptables -D FORWARD -p ${x.proto} -m set --dport ${toString x.destinationPort} --match-set vps-ranges src -j DROP || true
          ''
      )
      publicServices
    );

    forwardPorts =
      lib.mapAttrsToList
      (_: value: {
        sourcePort = value.sourcePort;
        destination = value.destination + ":" + toString value.destinationPort;
        proto = value.proto;
      })
      publicServices;
  };

  environment.etc."ipset.conf".text = lib.replaceStrings ["\n\n"] ["\n"] (lib.concatLines (
    [
      "create vps-ranges hash:net family ipv4 maxelem 1048576 hashsize 1048576 bucketsize 8 -exist"
      "create vps-ranges6 hash:net family ipv6 maxelem 1048576 hashsize 1048576 bucketsize 8 -exist"
    ]
    # filter and add ipv4 ranges
    ++ map (x: ''
      add vps-ranges ${x} -exist
    '') (lib.remove null (map (x:
      if (builtins.match ''^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$'' x != null)
      then x
      else null) (lib.splitString "\n" (builtins.readFile "${inputs.vps-ranges}/ip.txt"))))
    # Filter and add ipv6 ranges
    ++ map (x: ''
      add vps-ranges6 ${x} -exist
    '') (lib.remove null (map (x:
      if (builtins.match ''^(.{0,4}:){3}.{0,4}/[0-9]{2}$'' x != null)
      then x
      else null) (lib.splitString "\n" (builtins.readFile "${inputs.vps-ranges}/ip.txt"))))
  ));

  ### Nebula mesh network service definition Begins here ###

  services.nebula.networks."${name}" = {
    enable = true;

    # Lighthouse related config
    inherit isLighthouse;

    staticHostMap = lib.optionalAttrs (!isLighthouse) (lib.mergeAttrsList (lib.mapAttrsToList (hostname: info: {
        ${info.ip} = map (r: r + ":${toString port}") info.route;
      })
      lighthouses));

    lighthouses = lib.optionals (!isLighthouse) (lib.mapAttrsToList (_: x: x.ip) lighthouses);

    listen = {
      inherit port;
    };

    ca = hs-utils.sops.mkWarning config.sops "nebulaCACert" "nebula: CA cert secret not defined on ${config.networking.hostName}, using placeholder" ./ca.crt;
    cert = hs-utils.sops.mkWarning config.sops "nebulaCert" "nebula: cert secret not defined on ${config.networking.hostName}, using placeholder" ./test.crt;
    key = hs-utils.sops.mkWarning config.sops "nebulaKey" "nebula: key secret not defined on ${config.networking.hostName}, using placeholder" ./test.key;

    settings = {
      punchy = {
        punch = true;
        respond = true;
      };
      cipher = "chachapoly";

      pki = {
        # blocklist is a list of certificate fingerprints that we will refuse to talk to
        blocklist = [
          # Oops I uploaded a key
          "97112cb4678924463a7c567d2cc14d6e26f02e821451193e08f613d89beb05b1"
        ];
      };

      routines =
        if threads ? ${hostGroup}
        then threads.${hostGroup}
        else 2;
    };

    inherit isRelay;

    relays = lib.optionals (!isRelay) (lib.attrValues relayHosts);

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
