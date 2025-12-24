{
  lib,
  config,
  ...
}: {
  assertions = [
    {
      assertion = builtins.hasAttr "Pass" config.services.znc.config;
      message = "znc credentials not defined";
    }
  ];

  services.znc = {
    enable = true;
    mutable = false; # Overwrite configuration set by ZNC from the web and chat interfaces.
    useLegacyConfig = false; # Turn off services.znc.confOptions and their defaults.
    # openFirewall = true; # ZNC uses TCP port 5000 by default.
    config = {
      LoadModule = ["adminlog" "fail2ban"];
      User.hubko = {
        Admin = true;
        Nick = "hubofeverything";
        AltNick = "hubble-koda";
        LoadModule = ["chansaver" "controlpanel" "clientnotify"];
        Network.fuelrats = {
          RealName = "Hubble and Koda!";
          Server = "irc.fuelrats.com +6667";
          LoadModule = ["simple_away" "sasl" "route_replies"];
          Chan = {
            "#FuelRats" = {Detached = true;};
            "#Ratchat" = {Detached = false;};
          };
        };
      };
    };
  };
  services.nebula.networks."hsmn0".firewall.inbound = lib.optionals config.services.nebula.networks."hsmn0".enable [
    {
      port = "4000";
      proto = "tcp";
      group = "pc";
    }
  ];
}
