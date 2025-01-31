{
  lib,
  pkgs,
  config,
  ...
}: {
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/persist/git-server";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnKoFLIrn9/lB2Ymd60sL5EJOHvJTCN+0f/1JZYBAVF git@github-actions"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmUurzgVIwqMfMBppbdNyJ37R2CzLMjh7/Y00JWVofp hs-secrets"
    ];
  };

  users.groups.git = {};

  services.openssh = {
    enable = true;
    extraConfig = ''
      Match user git
        AllowTcpForwarding no
        AllowAgentForwarding no
        PasswordAuthentication no
        PermitTTY no
        X11Forwarding no

      Match Address 10.86.87.*
        AllowUsers git
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
