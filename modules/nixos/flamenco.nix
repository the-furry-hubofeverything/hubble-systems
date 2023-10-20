{ config, lib, pkgs, ... }: 
let 
  cfg = config.services.flamenco;
in {
  options.services.flamenco = {
    enable = lib.mkEnableOption "Flamenco, a render farm management software for Blender";
    package = lib.mkPackageOption pkgs "flamenco" {};

    role = lib.mkOption {
      description = lib.mdDoc "";
      default = "manager";
      type = lib.types.enum [ "manager" "worker" ];
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
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.flamenco = {
      description = "flamenco render farm software";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig ={
        ExecStartPre = "mkdir -p /etc/flamenco/";
        ExecStart = "${cfg.package}/flamenco-${cfg.role}";
      };
    };
  };
}