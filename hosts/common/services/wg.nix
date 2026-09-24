{
  lib,
  config,
  pkgs,
  hs-utils,
  ...
}: {
  assertions = [
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "wg: defaultSopsFile not empty, cannot continue";
    }
    {
      assertion = config.networking.nat.externalInterface != null;
      message = "wg: nat external interface not set.";
    }
    {
      assertion = !hs-utils.sops.isDefault config.sops "wgPrivateKey";
      message = "wg: wireguard secret key not defined";
    }
    {
      assertion = !hs-utils.sops.isDefault config.sops "wgPreSharedKey";
      message = "wg: wireguard secret key not defined";
    }
  ];

  networking.nat =
    (
      lib.optionalAttrs (!config.services.nebula.networks."hsmn0".isLighthouse)
      {
        enable = true;
        enableIPv6 = true;
        # IMPORTANT: SET EXTERNAL INTERFACES
      }
    )
    // {
      internalInterfaces = ["wg0"];
    };

  networking.firewall = {
    allowedUDPPorts = [53653];
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      "wg0" = {
        listenPort = 53653;
        privateKeyFile = config.sops.secrets.wgPrivateKey.path;
        
        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
        '';

        # Undo the above
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
        '';

        # peers set in hs-secrets
      };
    };
  };
}
