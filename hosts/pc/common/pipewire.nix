{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

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

  # Unset musnix's default cpu governor setting -
  # I'm sacrificing realtime-audio for a little bit
  # of flexibility in power management.
  powerManagement.cpuFreqGovernor = lib.mkForce null;
}
