{ config, lib, pkgs, inputs, hs-utils, ... }:
let
  gpu-autoselect = pkgs.writeText "gpu-autoselect.py" (builtins.readFile ./gpu-autoselect.py);
  managerHostname = "enterprise-asus-lcluster";
in {
  assertions = [
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "flamenco: defaultSopsFile not empty, cannot continue.";
    }
    {
      assertion = config.services.netbird.enable;
      messages = "flamenco: netbird not enabled, cannot continue.";
    }
  ];

  services.flamenco = {
    enable = true;
    package = pkgs.flamenco.override {
      blender = inputs.blender-bin.packages.${pkgs.system}.blender_3_6;
    };
    role = ["worker"];
    workerConfig = {
      manager_url = "http://100.106.28.233:5260";
    };

    managerConfig.variables."blenderArgs".values = [
      {
        platform = "all";
        value = "-b -y -P /run/flamenco/gpu-autoselect.py";
      }
    ];
  };

  # Samba is intolerant of extra newlines and what not.
  sops.templates.".smbcredentials".content = "username=${config.sops.placeholder.flamencoSambaUser}\npassword=${config.sops.placeholder.flamencoSambaPasswd}";

  boot.supportedFilesystems = ["cifs"];
  boot.kernelModules = ["cmac"]; # Needed due to titan being like "Could not allocate shash TFM 'cmac(aes)'"

  fileSystems = ( lib.optionalAttrs (config.networking.hostName != "${managerHostname}") 
  {
    "/srv/flamenco" = {
      device = "//${managerHostname}.gulo.dev/flamenco";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "gid=${toString config.users.groups.render.gid}"
        "uid=${toString config.users.users.render.uid}"
      ] ++ (
        if (!hs-utils.sops.isDefault config.sops "flamencoSambaUser" && !hs-utils.sops.isDefault config.sops "flamencoSambaPasswd") 
        then ["credentials=${config.sops.templates.".smbcredentials".path}"]
        else lib.warn 
          "flamenco: samba secrets not detected, default credentials used: username = flamenco, password = foobar" 
          ["user=flamenco" "password=foobar"]
      );
    };
  });

  systemd.tmpfiles.rules = [
    # WORKAROUND - I can't define the file under flamenco variables, or else the file
    #              would not be included in the nix store of the workers. 
    "L+ /run/flamenco/gpu-autoselect.py 0755 render render - ${gpu-autoselect}"
  ];
}