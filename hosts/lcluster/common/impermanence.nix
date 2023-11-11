{ ... }: {
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

 environment.persistence."/persist" = {
  hideMounts = true;
  directories = [
    "/etc/NetworkManager/system-connections"
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/var/lib/systemd/coredump"
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
}