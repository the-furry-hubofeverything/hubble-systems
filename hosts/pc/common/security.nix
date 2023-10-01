{...}: {
  # U2F support
  security.pam.u2f.cue = true;
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    polkit-1.u2fAuth = true;
    gnomeKeyring.u2fAuth = true;
  };
  security.unprivilegedUsernsClone = true; # Disable user namespace mitigation, which breaks flatpak and isn't necessary
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  security.polkit.enable = true;
}
