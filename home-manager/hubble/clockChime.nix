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
      message = "clockChime requires pipewire";
    }
  ];

  systemd.user.timers."clock-chime" = {
    Install.WantedBy = ["timers.target"];
    Timer = {
      OnCalendar = "*:0/15"; # ever multiple of fifteen on minutes
      AccuracySec = "1s";
      Unit = "clock-chime.service";
    };
  };

  systemd.user.services."clock-chime" = {
    Unit = {
      Description = "Clock Chimes";
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
