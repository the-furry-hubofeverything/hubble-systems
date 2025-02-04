{
  inputs,
  config,
  lib,
  ...
}: {
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  environment.persistence."/persist" = {
    hideMounts = true;
    directories =
      [
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/acme"
      ]
      ++ lib.optionals config.services.minecraft-servers.enable [
        config.services.minecraft-servers.dataDir
      ]
      ++ lib.optionals config.services.samba.enable [
        "/var/lib/samba"
      ]
      ++ lib.optionals config.services.vaultwarden.enable [
        "/var/lib/bitwarden_rs"
      ] 
      ++ lib.optionals config.services.prometheus.enable [
        ("/var/lib/" + config.services.prometheus.stateDir)
      ];

    files = [
      "/etc/adjtime"
      "/etc/machine-id"

      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"

      "/var/lib/NetworkManager/secret_key"
      "/var/lib/NetworkManager/seen-bssids"
      "/var/lib/NetworkManager/timestamps"

      "/var/lib/logrotate.status"
    ];
  };

  fileSystems."/".options = ["noexec"];
  fileSystems."/var/log".options = ["noexec"];

  sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
}
