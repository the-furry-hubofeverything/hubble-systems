{
  config,
  pkgs,
  ...
}: {
  services.logind.lidSwitch = "ignore";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.


  boot.kernelModules = [
    "usb_storage"   # USB mass storage support
  ];

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    git
    
    udisks   # userspace mount to /run/media

    # Experiemental
    # flamenco
  ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.openFirewall = true;

  services.netbird.enable = true;

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/netbird"
      "/var/lib/acme"
    ];
  };

  # TODO setup remote jobs using best practices
  nix.settings.trusted-users = ["@wheel" "hubble"];

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = ["panic=1" "boot.panic_on_fail"];

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;
}
