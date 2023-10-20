{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.flamenco;
  configFile =
    pkgs.writeTextFile {
    };
in {
  options.services.flamenco = {
    enable = lib.mkEnableOption "Flamenco, a render farm management software for Blender";
    package = lib.mkPackageOption pkgs "flamenco" {};

    role = lib.mkOption {
      description = lib.mdDoc "";
      default = "manager";
      type = lib.types.enum ["manager" "worker"];
    };

    user = lib.mkOption {
      description = lib.mdDoc "User under which flamenco runs under";
      default = "flamenco";
      type = lib.types.str;
    };

    group = lib.mkOption {
      description = lib.mdDoc "Group under which flamenco runs under";
      default = "flamenco";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      description = lib.mdDoc "";
      default = {};
      type = lib.types.attrs;
    };

    settingsFile = lib.mkOption {
      description = lib.mdDoc "";
      default = null;
      type = lib.types.nullor lib.types.path;
    };

    openFirewall = lib.mkEnableOption "service ports in the firewall";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall && cfg.role == "manager") ["8080"];

    systemd.services.flamenco = {
      description = "flamenco render farm software";
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        ExecStartPre = "mkdir -p /etc/flamenco/";
        ExecStart = "${cfg.package}/flamenco-${cfg.role} -restart-exit-status 47";

        DynamicUser = true;
        User = cfg.user;
        Group = cfg.group;

        RestartForceExitStatus = 47;
        Restart = "on-failure";
      };
    };

    users = {
      users = lib.optionalAttrs (cfg.user == cfg.user.default) {
        "${cfg.user}" = {
          description = "Flamenco service user";
          group = cfg.group;
          isSystemUser = true;
        };
      };
      groups = lib.optionalAttrs (cfg.group == cfg.group.default) {
        "${cfg.group}" = {};
      };
    };
  };
}
