{
  pkgs,
  hostConfig,
  ...
}: let
  chime = pkgs.fetchurl {
    url = "https://www.trekcore.com/audio/computer/computerbeep_42.mp3";
    hash = "sha256-Pqfgt9sHeUkcLCOBHbYUUCLmHmFlIif99taQaSlnOcU=";
  };
in {
  assertions = [
    {
      assertion = hostConfig.config.services.pipewire.enable;
      message = "chimeByHour requires pipewire";
    }
  ];

  systemd.user.timers."chime-by-hour" = {
    Install.WantedBy = ["timers.target"];
    Timer = {
      OnCalendar = "hourly";
      Unit = "chime-by-hour.service";
    };
  };

  systemd.user.services."chime-by-hour" = {
    Unit = {
      Description = "Hourly Chime";
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "chime.sh" ''
        cat /dev/zero | head -c 23000 | ${hostConfig.config.services.pipewire.package}/bin/pw-play -a -
        ${hostConfig.config.services.pipewire.package}/bin/pw-play ${chime}
      '';
    };
  };
}
