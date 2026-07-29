{
  config,
  pkgs,
  lib,
  ...
}: {
  users.users."nixremote" = {
    createHome = true;
    isSystemUser = true;
    group = "nogroup";
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "nebula"
    ];
    homeMode = "540";
  };

  nix.settings = {
    trusted-users = ["nixremote"];
  };

  services.openssh.extraConfig = ''
    Match User nixremote
      AllowTcpForwarding no
      AllowAgentForwarding no
      PasswordAuthentication no
      X11Forwarding no
  '';

  services.nebula.networks."hsmn0".firewall.inbound =
    lib.optionals config.services.nebula.networks."hsmn0".enable
    [
      {
        group = "pc";
        port = 22;
        proto = "tcp";
      }
    ];
}
