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
      ++ lib.optionals (builtins.hasAttr "minecraft-servers" config.services && config.services.minecraft-servers.enable) [
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
      ]
      ++ lib.optionals (config.services.grafana.enable) (map (x: {
          directory = x;
          group = "grafana";
          user = "grafana";
        })
        [
          "/var/lib/grafana/plugins"
          "/var/lib/grafana/data"
        ]);

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

  # TODO Gen2 - exclude /tmp from noexec
  # dh_sqlite.NativeLibraryNotFoundException: No native library found -> IT DROVE ME NUTS
  fileSystems."/var/log".options = ["noexec"];

  sops.age.sshKeyPaths = lib.optionals (config.sops.age.keyFile == null) ["/persist/etc/ssh/ssh_host_ed25519_key"];
}
