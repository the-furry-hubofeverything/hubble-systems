{
  pkgs,
  config,
  ...
}: {
  boot.plymouth.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.coredump.enable = false; # Takes too long, too much resources and not often used. Can disable whenever.

  # Printer support
  services.printing.enable = true;
  # Mitigating CVE-2024-47076, CVE-2024-47175, CVE-2024-47176 and CVE-2024-47177
  systemd.services.cups-browsed.enable = false;

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  services.syncthing.openDefaultPorts = true;

  services.nebula.networks."hsmn0".firewall = let
    groups = [
      "mobile"
      "pc"
    ];
  in {
    inbound =
      builtins.map
      (group: {
        port = "22000";
        inherit group;
        proto = "any";
      })
      groups
      ++ builtins.map (group: {
        port = "21027";
        inherit group;
        proto = "udp";
      })
      groups;
  };

  hardware.opentabletdriver = {
    enable = true;
  };

  # bluetooth settings
  hardware.bluetooth = {

    package = pkgs.bluez-experimental;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # Logitech Wireless peripheral udev support (including unify)
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # OpenGL for desktop and other applications
  hardware.graphics = {
    enable = true;
    # Vulkan support
    enable32Bit = true;
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    libfido2 # u2f support
    file

    nvtopPackages.full
    htop
    killall

    kitty
    wii-pointer

    # FHS compatibility shell using appimage environment defaults
    (pkgs.buildFHSEnv (appimageTools.defaultFhsEnvArgs
      // {
        name = "fhs-run";

        targetpkgs = pkgs: (with pkgs; [
          # add additional packages here
        ]);

        environment = {
          QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins/platforms";
        };

        runScript = writeShellScript "fhs-run" ''
          exec "$@"
        '';
      }))

    # Same thing, but a shell.
    (pkgs.buildFHSEnv (appimageTools.defaultFhsEnvArgs
      // {
        name = "fhs";

        targetpkgs = pkgs: (with pkgs; [
          # add additional packages here
        ]);

        environment = {
          QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins/platforms";
        };

        profile = ''export FHS=1'';
        runScript = "bash";
      }))
  ];

  hardware.enableAllFirmware = true;

  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      unifont
      winePackages.fonts

      quicksand
      ubuntu-classic
      comic-neue
      koulen
      inter

      font-awesome
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # For compatibility with flatpak etc.
  fonts.fontDir.enable = true;

  fonts.fontconfig.defaultFonts.sansSerif = ["Inter"];

  # Support F1-F10 Keys on lofree flow keyboard
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  boot.kernel.sysctl = {
    # Allow emergency sysrq reboot "reisub"
    "kernel.sysrq" = 246;
  };
}
