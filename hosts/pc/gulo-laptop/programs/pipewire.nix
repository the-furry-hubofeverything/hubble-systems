{lib, ...}: {
  services.pipewire.extraConfig.pipewire."92-clock-rates.conf" = {
    "context.properties" = {
      # computer can't handle below 128 sample rate
      "default.clock.quantum" = lib.mkForce 128;
      "default.clock.min-quantum" = lib.mkForce 128;
    };
  };
}
