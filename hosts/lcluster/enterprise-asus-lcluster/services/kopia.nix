{
  lib,
  config,
  ...
}: {
  users.users.kopia = {
    isSystemUser = true;
    group = "kopia";
    home = "/mass/kopia/backup";
    # Authorized keys in hs-secrets
  };

  users.groups.kopia = {};

  services.openssh = {
    enable = true;
    extraConfig = ''
      Match user kopia
        AllowTcpForwarding no
        AllowAgentForwarding no
        PasswordAuthentication no
        PermitTTY no
        X11Forwarding no 
        ForceCommand internal-sftp

      Match Address 10.86.87.*
        AllowUsers kopia
    '';
  };

  services.nebula.networks."hsmn0".firewall.inbound =
    lib.optionals config.services.nebula.networks."hsmn0".enable
    [
      {
        group = "remote";
        port = 22;
        proto = "tcp";
      }
      {
        group = "pc";
        port = 22;
        proto = "tcp";
      }
    ];
}
