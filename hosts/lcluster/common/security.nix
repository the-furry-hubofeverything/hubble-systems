{
  config,
  lib,
  hs-utils,
  ...
}: let
  mkPassword = secret: fallback: user: {
    # Checks if secret is set, if not use fallback as password.
    hashedPasswordFile = if hs-utils.sops.isDefault config.sops secret
      then lib.warn "Password secret not imported for the user ${user}, setting path to null" null
      else config.sops.secrets.${secret}.path;

    password = if hs-utils.sops.isDefault config.sops secret
      then lib.warn "Debug password for ${user} set: ${fallback}" fallback
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
  security.lockKernelModules = true;

  fileSystems."/".options = [ "noexec" ];
  fileSystems."/var/log".options = [ "noexec" ];

  # TODO remove ssh RSA key

  # TODO Set passwords declaratively for all systems
  users.mutableUsers = false;

  sops.secrets.hubblePasswd.neededForUsers = true;
  sops.secrets.rootPasswd.neededForUsers = true;

  sops.gnupg.sshKeyPaths = [];

  users.users = {
    "hubble" = mkPassword "hubblePasswd" "tank-weasel" "hubble";
    "root" = mkPassword "rootPasswd" "hubble-systems" "root";
  };
}
