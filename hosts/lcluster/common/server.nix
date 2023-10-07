{ config, pkgs, ... }:
{
  services.logind.lidSwitch = "ignore";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  environment.systemPackages = [
    pkgs.kitty.terminfo
  ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.openFirewall = true;

  # TODO setup remote jobs using best practices
  nix.settings.trusted-users = [ "@wheel" "hubble" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" "vga=0x317" "nomodeset" ];

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;
}