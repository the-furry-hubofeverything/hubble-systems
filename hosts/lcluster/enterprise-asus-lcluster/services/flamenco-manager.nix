{ config, ... }: 
let 
  port = 5260;
in {
  assertions = [
    {
      assertion = config.services.flamenco.enable;
      message = "flamenco-manager: Flamenco not enabled, is flamenco.nix imported for lcluster hosts?";
    }
  ];

  services.flamenco = {
    listen = {inherit port;};
    role = ["manager"];
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "L+ /srv/flamenco 0755 render render - /main/large/flamenco"
  ];
}