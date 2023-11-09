{...}: {
  security.lockKernelModules = true;

  fileSystems."/".options = [ "noexec" ];
  fileSystems."/var/log".options = [ "noexec" ];

  # TODO remove ssh RSA key
}
