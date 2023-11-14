{ config, ... }: {
  security.lockKernelModules = true;

  fileSystems."/".options = [ "noexec" ];
  fileSystems."/var/log".options = [ "noexec" ];

  # TODO remove ssh RSA key

  users.mutableUsers = false;

  sops.secrets.hubblePasswd.neededForUsers = true;
  sops.secrets.rootPasswd.neededForUsers = true;

  sops.gnupg.sshKeyPaths = [];
  sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key"];

  users.users = {
    "hubble".passwordFile = config.sops.secrets.hubblePasswd.path;
    "root".passwordFile = config.sops.secrets.rootPasswd.path;
  };
}
