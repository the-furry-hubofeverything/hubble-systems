{pkgs, ...}: {
  # U2F support
  security.pam.u2f.settings.cue = true;
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    polkit-1.u2fAuth = true;
    gnomeKeyring.u2fAuth = true;
  };
  security.unprivilegedUsernsClone = true; # Disable user namespace mitigation, which breaks flatpak and isn't necessary
  # rtkit is optional but recommended for pipewire
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # Using polkit-gnome
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  security.tpm2.enable = true;
}
