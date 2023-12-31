{
  pkgs,
  config,
  ...
}: {
  boot.plymouth.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # Printer support
  services.printing.enable = true;

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  # Enable pipewire and disable pulseaudio
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # bluetooth settings
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # v4l2loopback
  boot.extraModulePackages = [
    config.boot.kernelPackages.v4l2loopback
  ];

  # Logitech Wireless peripheral udev support (including unify)
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # OpenGL for desktop and other applications
  hardware.opengl = {
    enable = true;
    # Vulkan support
    driSupport = true;
    driSupport32Bit = true;
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    libfido2 # u2f support
    file

    nvtop
    htop
    killall

    kitty
    netbird-ui
  ];

  hardware.enableAllFirmware = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    unifont
    winePackages.fonts
    
    unstable.quicksand
    ubuntu_font_family
    comic-neue
    koulen
    inter
  ];

  fonts.fontconfig.defaultFonts.sansSerif = [ "Inter" ];

  # https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-1326957279
  # Workaround for 119433
  
  fonts.fontDir.enable = true;

  system.fsPackages = [pkgs.bindfs];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.packages;
      pathsToLink = ["/share/fonts"];
    };
  in {
    # Create an FHS mount to support flatpak host icons/fonts
    "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
    "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
  };

  # Netbird VPN
  services.netbird = {
    enable = true;
  };
}
