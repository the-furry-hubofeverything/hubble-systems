{pkgs, ...}: {
  imports = [
    ./security.nix
  ];

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    settings.PermitRootLogin = "no";
  };

  # Enable sound.
  services.pulseaudio.enable = true;

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  boot.kernelModules = [
    "usb_storage" # USB mass storage support
  ];
  services.udisks2.enable = true; # userspace mount to /run/media

  environment.systemPackages = with pkgs; [
    kitty.terminfo
    git
  ];

  # TODO setup remote jobs using best practices
  nix.settings.trusted-users = ["@wheel" "hubble"];

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = ["panic=1" "boot.panic_on_fail"];

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;
}
