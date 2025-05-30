{
  config,
  lib,
  hs-utils,
  ...
}: let
  mkPassword = secret: fallback: user: {
    # Checks if secret is set, if not use fallback as password.
    hashedPasswordFile = hs-utils.sops.mkWarning config.sops secret "Password secret not imported for the user ${user} on ${config.networking.hostName}, setting path to null" null;

    password =
      if hs-utils.sops.isDefault config.sops secret
      then lib.warn "Debug password for ${user} on ${config.networking.hostName} set: ${fallback}" fallback
      else null;
  };

  mkAssertion = secret: user: {
    # If any secrets are undefined that is NOT on *-common configuration
    assertion = !hs-utils.sops.isDefault config.sops secret != (builtins.match "(.*)-common" config.networking.hostName);
    message = "security: password for ${user} not defined on configuration, cannot continue";
  };
in {
  assertions = [
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "security: defaultSopsFile not empty, cannot continue";
    }
    (mkAssertion "hubblePasswd" "hubble")
    (mkAssertion "rootPasswd" "root")
  ];

  # TODO: instead of locking kernel modules, maybe just provide audit trail? (auditd)
  # https://github.com/czerwonk/nixfiles/blob/26295d470f3b505d77b07017c6bc4039647dc06a/nixos/hardening/audit.nix
  # security.lockKernelModules = true;

  # TODO remove ssh RSA key

  users.mutableUsers = false;

  sops.secrets.hubblePasswd.neededForUsers = true;
  sops.secrets.rootPasswd.neededForUsers = true;

  sops.gnupg.sshKeyPaths = [];
  # sops.age.sshKeyPaths = [];

  users.users = {
    "hubble" = mkPassword "hubblePasswd" "tank-weasel" "hubble";
    "root" = mkPassword "rootPasswd" "hubble-systems" "root";
  };
}
