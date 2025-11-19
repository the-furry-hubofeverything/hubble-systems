{...}: {
  users.groups."nixremote" = { };
  users.users."nixremote" = {
    createHome = true;
    group = "nixremote";
    isSystemUser = true;
    homeMode = 540;
  };

  services.openssh.extraConfig = ''
    Match user nixremote
      AllowTcpForwarding no
      AllowAgentForwarding no
      PasswordAuthentication no
      X11Forwarding no

    Match Address 10.86.87.*
      AllowUsers nixremote
  '';

  # Modified from https://github.com/cole-h/nixos-config
  security.sudo.extraRules = [
    {
      users = ["nixremote"];
      commands = [
        {
          command = "/nix/store/*/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nix-env";
          options = ["NOPASSWD"];
        }
        {
          command = ''/bin/sh -c "readlink -e /nix/var/nix/profiles/system || readlink -e /run/current-system"'';
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nix-collect-garbage";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
