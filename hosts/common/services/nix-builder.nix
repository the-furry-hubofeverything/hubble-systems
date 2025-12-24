{
  config,
  pkgs,
  lib,
  ...
}: {
  users.groups."nixremote" = {};
  users.users."nixremote" = {
    createHome = true;
    isSystemUser = true;
    group = "nixremote";
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "nebula"
    ];
    homeMode = "540";
  };

  nix.settings = {
    trusted-users = ["nixremote"];
  };

  services.openssh.extraConfig = ''
    Match User nixremote
      AllowTcpForwarding no
      AllowAgentForwarding no
      PasswordAuthentication no
      X11Forwarding no
  '';

  # Modified from https://github.com/NobbZ/nixos-config/blob/main/nixos/modules/switcher.nix
  # MIT license, Copyright (c) 2020 Norbert Melzer
  security.sudo.extraRules = let
    commandPrefix = "/run/current-system/sw";
    profilePath = "/nix/store/.{32}-nixos-system-${config.networking.hostName}-.{22}";
    nixEnvCmd = "${commandPrefix}/bin/nix-env";
    systemdRunCmd = "${commandPrefix}/bin/env ^NIXOS_INSTALL_BOOTLOADER=[0-1] systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER --collect --no-ask-password --pipe --quiet --service-type=exec --unit=nixos-rebuild-switch-to-configuration";
    options = ["NOPASSWD"];
    mkRule = command: {
      commands = [{inherit command options;}];
      groups = ["nixremote"];
    };
  in [
    (mkRule "${systemdRunCmd} ${profilePath}/bin/switch-to-configuration (switch|boot|test)$")
    (mkRule "${nixEnvCmd} ^-p /nix/var/nix/profiles/system --set ${profilePath}$")
  ];

  services.nebula.networks."hsmn0".firewall.inbound =
    lib.optionals config.services.nebula.networks."hsmn0".enable
    [
      {
        group = "pc";
        port = 22;
        proto = "tcp";
      }
    ];
}
