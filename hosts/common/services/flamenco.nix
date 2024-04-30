{
  config,
  lib,
  pkgs,
  inputs,
  hs-utils,
  ...
}: let
  gpu-autoselect = pkgs.writeText "gpu-autoselect.py" (builtins.readFile ./gpu-autoselect.py);
  managerHostname = "enterprise-asus-lcluster";
  managerFileDir = "/main/large/flamenco";
  isManager = config.networking.hostName == managerHostname;
  port = 5260;
in {
  assertions = [
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "flamenco: defaultSopsFile not empty, cannot continue.";
    }
    {
      assertion = !isManager || (config.services.nginx.enable && config.services.nginx.virtualHosts ? "${config.networking.hostName}.gulo.dev");
      message = "flamenco: ${config.networking.hostName}.gulo.dev is undefinied, this depends on acme-nginx-rp.nix";
    }
    {
      assertion = config.services.nebula.networks ? "hsmn0";
      messages = "flamenco: nebula network not defined, cannot continue.";
    }
    {
      assertion = config.services.nebula.networks."hsmn0".enable;
      messages = "flamenco: nebula network not enabled, cannot continue.";
    }
  ];

  services.flamenco = {
    enable = true;
    listen = lib.optionalAttrs isManager {inherit port;};

    package = pkgs.flamenco.override {
      blender = inputs.blender-bin.packages.${pkgs.system}.blender_3_6;

      # I need go 1.22, but flamenco isn't upstream yet, soooooo....
      # TODO remove when flamenco is upstream
      go = pkgs.unstable.go;
      buildGoModule = pkgs.unstable.buildGoModule;
    };
    role = ["worker"] ++ lib.optionals isManager ["manager"];
    workerConfig = {
      manager_url = "https://flamenco.gulo.dev";
    };

    managerConfig.variables."blenderArgs".values = [
      {
        platform = "all";
        value = "-b -y -P /run/flamenco/gpu-autoselect.py";
      }
    ];
    openFirewall = false;
  };

  systemd.services."flamenco-worker".wantedBy = lib.optionals (config.networking.hostName == "Gulo-Laptop") (lib.mkForce []);

  # Samba is intolerant of extra newlines and what not.
  sops.templates.".smbcredentials".content = "username=${config.sops.placeholder.flamencoSambaUser}\npassword=${config.sops.placeholder.flamencoSambaPasswd}";

  boot.supportedFilesystems = ["cifs"];
  boot.kernelModules = ["cmac"]; # Needed due to titan being like "Could not allocate shash TFM 'cmac(aes)'"

  fileSystems = (lib.optionalAttrs (!isManager) {
    "/srv/flamenco" = {
      device = "//flamenco.gulo.dev/flamenco";
      fsType = "cifs";
      options =
        [
          "x-systemd.automount"
          "noauto"
          "x-systemd.idle-timeout=60"
          "x-systemd.device-timeout=5s"
          "x-systemd.mount-timeout=5s"
          "gid=${toString config.users.groups.render.gid}"
          "uid=${toString config.users.users.render.uid}"
        ]
        ++ (
          if (!hs-utils.sops.isDefault config.sops "flamencoSambaUser" && !hs-utils.sops.isDefault config.sops "flamencoSambaPasswd")
          then ["credentials=${config.sops.templates.".smbcredentials".path}"]
          else
            lib.warn
            "flamenco: samba secrets not detected, default credentials used: username = flamenco, password = foobar"
            ["user=flamenco" "password=foobar"]
        );
    };
  });

  systemd.tmpfiles.rules =
    [
      # WORKAROUND - I can't define the file under flamenco variables, or else the file
      #              would not be included in the nix store of the workers.
      "L+ /run/flamenco/gpu-autoselect.py 0755 render render - ${gpu-autoselect}"
    ]
    ++ lib.optionals isManager [
      # The manager is hosting the files
      "L+ /srv/flamenco 0755 render render - ${managerFileDir}"
    ];

  services.nginx.virtualHosts."flamenco.gulo.dev" = let
    proxyPass = "http://127.0.0.1:${toString port}";
  in {
    useACMEHost = "gulo.dev";
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 16000M;
    '';

    locations."/" = {
      tryFiles = "/non-existent @$http_upgrade";
    };

    locations."@websocket" = {
      inherit proxyPass;
      proxyWebsockets = true;
    };

    locations."@" = {
      inherit proxyPass;
    };
  };
}
