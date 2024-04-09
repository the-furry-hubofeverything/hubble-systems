{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.flamenco;
  yaml = pkgs.formats.yaml {};
  roleIs = role: lib.any (x: x == role) cfg.role;
  defaultConfig = {
    manager = {
      _meta = {version = 3;};
      manager_name = "Flamenco Manager";
      listen = ":${builtins.toString cfg.port}";
      autodiscoverable = true;

      shared_storage_path = "/srv/flamenco";
      shaman = {
        enabled = true;
        garbageCollect = {
          period = "24h0m0s";
          maxAge = "7440m0s";
          extraCheckoutPaths = [];
        };
      };

      task_timeout = "10m0s";
      worker_timeout = "1m0s";
      blocklist_threshold = 3;
      task_fail_after_softfail_count = 3;

      variables = {
        "blender" = {
          values = [
            {
              platform = "linux";
              value = "blender";
            }
            {
              platform = "windows";
              value = "blender";
            }
            {
              platform = "darwin";
              value = "blender";
            }
          ];
        };

        "blenderArgs" = {
          values = [
            {
              platform = "all";
              value = "-b -y";
            }
          ];
        };
      };
    };

    worker = {
      task_types = ["blender" "ffmpeg" "file-managerment" "misc"];
      restart_exit_code = 47;
    };
  };

  configFile = {
    manager = yaml.generate "flamenco-manager.yaml" (defaultConfig.manager // cfg.managerConfig);
    worker = yaml.generate "flamenco-worker.yaml" (defaultConfig.worker // cfg.workerConfig);
  };

  mkService = role: {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    description = "flamenco ${role}";
    environment =
      if (role == "worker")
      then {
        FLAMENCO_HOME = cfg.home;
        FLAMENCO_WORKER_NAME =
          if (!builtins.isNull cfg.workerConfig.worker_name)
          then cfg.workerConfig.worker_name
          else null;
      }
      else {};

    serviceConfig = {
      ExecStart = "${cfg.package}/bin/flamenco-${role}";

      User = cfg.user;
      Group = cfg.group;
      StateDirectory = "flamenco";
      StateDirectoryMode = "0755";
      WorkingDirectory = "${pkgs.linkFarm "flamenco-${role}-wd" [
        {
          name = "flamenco-${role}.yaml";
          path = "${configFile.${role}}";
        }
      ]}";

      RestartForceExitStatus =
        if (role == "worker")
        then cfg.workerConfig.restart_exit_code
        else null;
      Restart = "on-failure";
    };
  };
in {
  options.services.flamenco = with lib.types; {
    enable = lib.mkEnableOption "Flamenco, a render farm management software for Blender";
    package = lib.mkPackageOption pkgs "flamenco" {};
    openFirewall = lib.mkEnableOption "service ports in the firewall";

    role = lib.mkOption {
      description = lib.mdDoc "Flamenco role that this machine should take.";
      default = ["worker"];
      type = listOf (enum ["manager" "worker"]);
    };

    user = lib.mkOption {
      description = lib.mdDoc "User under which flamenco runs under.";
      default = "flamenco";
      type = str;
    };

    group = lib.mkOption {
      description = lib.mdDoc "Group under which flamenco runs under.";
      default = "flamenco";
      type = str;
    };

    home = lib.mkOption {
      description = lib.mdDoc "Directory for worker-specific files.";
      default = "${cfg.stateDir}/worker";
      type = path;
    };

    port = lib.mkOption {
      description = lib.mdDoc "Flamenco Manager port.";
      default = 8080;
      type = port;
    };

    managerConfig = lib.mkOption {
      description = lib.mdDoc "Manager configuration";
      default = defaultConfig.manager;
      type = submodule {
        freeformType = attrsOf anything;
        options = {
          manager_name = lib.mkOption {
            description = lib.mdDoc "The name of the Manager.";
            default = "Flamenco Manager";
            type = str;
          };
          database = lib.mkOption {
            description = lib.mdDoc "Path of the database";
            default = "${cfg.stateDir}/flamenco-manager.sqlite";
            type = path;
          };
          local_manager_storage_path = lib.mkOption {
            description = lib.mdDoc "Path for Flamenco manager state files";
            default = "${cfg.stateDir}/flamenco-manager-storage";
          };
        };
      };
    };

    workerConfig = lib.mkOption {
      description = lib.mdDoc "Worker configuration";
      default = defaultConfig.worker;
      type = submodule {
        freeformType = attrsOf anything;
        options = {
          worker_name = lib.mkOption {
            description = "The name of the Worker. If not specified, the worker will use the hostname.";
            default = null;
            type = nullOr str;
          };
          manager_url = lib.mkOption {
            description = lib.mdDoc "The URL of the Manager to connect to. If the setting is blank (or removed altogether) the Worker will try to auto-detect the Manager on the network.";
            default = null;
            type = nullOr str;
          };
          restart_exit_code = lib.mkOption {
            description = lib.mdDoc "Having this set to a non-zero value will mark this Worker as ‘restartable’.";
            default = 47;
            type = int;
          };
        };
      };
    };

    stateDir = lib.mkOption {
      description = lib.mdDoc "Specifies the directory in which flamenco state files and credentials reside.";
      default = "/var/lib/flamenco";
      type = path;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall && roleIs "manager") [(cfg.managerConfg.listen)];

    systemd.services = {
      flamenco-manager = lib.mkIf (roleIs "manager") (mkService "manager");
      flamenco-worker = lib.mkIf (roleIs "worker") (mkService "worker");
    };

    users = {
      users = lib.optionalAttrs (cfg.user == "flamenco") {
        "${cfg.user}" = {
          description = "Flamenco service user";
          group = cfg.group;
          isSystemUser = true;
        };
      };
      groups = lib.optionalAttrs (cfg.group == "flamenco") {
        "${cfg.group}" = {};
      };
    };
  };
}
