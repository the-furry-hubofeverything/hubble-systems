{
  pkgs,
  config,
  ...
}: {
  boot.plymouth.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # Printer support
  # Mitigating CVE-2024-47076, CVE-2024-47175, CVE-2024-47176 and CVE-2024-47177
  # services.printing.enable = true;

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

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
  ];

  hardware.enableAllFirmware = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    unifont
    winePackages.fonts

    quicksand
    ubuntu_font_family
    comic-neue
    koulen
    inter
  ];

  # For compatibility with flatpak etc.
  fonts.fontDir.enable = true;

  fonts.fontconfig.defaultFonts.sansSerif = ["Inter"];

  boot.kernel.sysctl = {
    # Allow emergency sysrq reboot "reisub"
    "kernel.sysrq" = 246;
  };
}
