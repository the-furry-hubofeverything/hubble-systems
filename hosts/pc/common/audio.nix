{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.musnix.nixosModules.musnix
  ];
  
  # Enable pipewire and disable pulseaudio
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  services.pipewire.extraConfig.pipewire."92-clock-rates.conf" = {
    "context.properties" = {
      # Avoids resampling
      "default.clock.allowed-rates" = [44100 48000 88200 96000];
      # Low latency, but some flexibility
      "default.clock.quantum" = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 4096;
    };
  };

  # Various audio optimizations
  musnix.enable = true;

  # various daws and stuff
  environment.systemPackages = [
    pkgs.sfizz
    pkgs.carla
    pkgs.unstable.ardour
    pkgs.lsp-plugins
    pkgs.dragonfly-reverb
    pkgs.drumgizmo
    pkgs.drumkv1
    pkgs.geonkick
    pkgs.infamousPlugins
    pkgs.master_me
    pkgs.noise-repellent
    pkgs.odin2
    pkgs.opnplug
    pkgs.padthv1
    pkgs.rubberband
    pkgs.samplv1
    pkgs.setbfree
    pkgs.sorcer
    pkgs.wolf-shaper
    pkgs.zynaddsubfx
    pkgs.yoshimi
    pkgs.zam-plugins
    pkgs.ams
    pkgs.adlplug
    pkgs.artyFX
    pkgs.x42-avldrums
  ];

  # Unset musnix's default cpu governor setting -
  # I'm sacrificing realtime-audio for a little bit
  # of flexibility in power management.
  powerManagement.cpuFreqGovernor = lib.mkForce null;
}
