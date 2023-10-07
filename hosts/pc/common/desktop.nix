{pkgs, ...}: {
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # bluetooth settings
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };
  # Better codecs for Bluetooth devices
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

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
    wireplumber # screenshare stuffs
    file

    nvtop
    htop
    killall

    kitty
  ];

  hardware.enableAllFirmware = true;
}
