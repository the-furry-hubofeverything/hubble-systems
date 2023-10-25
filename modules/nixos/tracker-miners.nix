# Tracker Miners daemons.

{ config, pkgs, lib, ... }:

let 
 cfg = config.services.gnome.tracker-miners;
in
{

  meta = {
    maintainers = lib.teams.gnome.members;
  };

  imports = [
    # Added 2021-05-07
    (lib.mkRenamedOptionModule
      [ "services" "gnome3" "tracker-miners" "enable" ]
      [ "services" "gnome" "tracker-miners" "enable" ]
    )
  ];

  ###### interface

  options = {
    services.gnome.tracker-miners = {
      enable = lib.mkEnableOption "Tracker miners, indexing services for Tracker search engine and metadata storage system";
      package = lib.mkPackageOption pkgs "tracker-miners" {};
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    services.dbus.packages = [ cfg.package ];

    systemd.packages = [ cfg.package ];

    services.gnome.tracker.subcommandPackages = [ cfg.package ];

  };

}