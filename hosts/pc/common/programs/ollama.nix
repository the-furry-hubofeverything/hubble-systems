{lib,pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  # Prevents start on boot
  systemd.services."ollama".wantedBy = lib.mkForce [];
}
