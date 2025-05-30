{lib, ...}: {
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  # Prevents start on boot
  systemd.services."ollama".wantedBy = lib.mkForce [];
}
