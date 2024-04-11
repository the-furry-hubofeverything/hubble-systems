{config, lib, hs-utils, ...}: {
  sops.templates.".smbcredentials".content = "username=${config.sops.placeholder.flamencoSambaUser}\npassword=${config.sops.placeholder.flamencoSambaPasswd}";

  fileSystems."/srv/flamenco" = {
    device = "//100.106.28.233/flamenco";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "uid=1000"
      "gid=${toString config.users.groups.users.gid}"
    ] ++ (
      if (!hs-utils.sops.isDefault config.sops "flamencoSambaUser" && !hs-utils.sops.isDefault config.sops "flamencoSambaPasswd") 
      then ["credentials=${config.sops.templates.".smbcredentials".path}"]
      else lib.warn 
        "flamenco: samba secrets not detected, default credentials used: username = flamenco, password = foobar" 
        ["user=flamenco" "password=foobar"]
    );
  };
}
