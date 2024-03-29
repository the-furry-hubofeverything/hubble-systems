{ config, ... }: {
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
    "hubble".hashedPasswordFile = config.sops.secrets.hubblePasswd.path;
    "root".hashedPasswordFile = config.sops.secrets.rootPasswd.path;
  };
}
