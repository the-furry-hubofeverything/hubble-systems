{
  lib,
  config,
  ...
}: {
  boot.kernel.sysctl = {
    # Restrict ptrace() usage to processes with a pre-defined relationship
    # (e.g., parent/child)
    "kernel.yama.ptrace_scope" = lib.mkOverride 500 1;

    # Hide kptrs even for processes with CAP_SYSLOG
    "kernel.kptr_restrict" = lib.mkOverride 500 2;

    # Disable bpf() JIT (to eliminate spray attacks)
    "net.core.bpf_jit_enable" = lib.mkDefault false;

    # Disable ftrace debugging
    "kernel.ftrace_enabled" = lib.mkDefault false;

    # Enable strict reverse path filtering (that is, do not attempt to route
    # packets that "obviously" do not belong to the iface's network; dropped
    # packets are logged as martians).
    "net.ipv4.conf.all.log_martians" = lib.mkDefault true;
    "net.ipv4.conf.all.rp_filter" = lib.mkDefault "1";
    "net.ipv4.conf.default.log_martians" = lib.mkDefault true;
    "net.ipv4.conf.default.rp_filter" = lib.mkDefault "1";

    # Ignore broadcast ICMP (mitigate SMURF)
    "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault true;

    # Ignore incoming ICMP redirects (note: default is needed to ensure that the
    # setting is applied to interfaces added after the sysctls are set)
    "net.ipv4.conf.all.accept_redirects" = lib.mkDefault false;
    "net.ipv4.conf.all.secure_redirects" = lib.mkDefault false;
    "net.ipv4.conf.default.accept_redirects" = lib.mkDefault false;
    "net.ipv4.conf.default.secure_redirects" = lib.mkDefault false;
    "net.ipv6.conf.all.accept_redirects" = lib.mkDefault false;
    "net.ipv6.conf.default.accept_redirects" = lib.mkDefault false;

    # Ignore outgoing ICMP redirects (this is ipv4 only)
    "net.ipv4.conf.all.send_redirects" = lib.mkDefault false;
    "net.ipv4.conf.default.send_redirects" = lib.mkDefault false;
  };

  boot.kernelParams = [
    # Slab/slub sanity checks, redzoning, and poisoning
    "slub_debug=FZP"

    # Overwrite free'd memory
    "page_poison=1"

    # Enable page allocator randomization
    "page_alloc.shuffle=1"
  ];

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs" # use ntfs3
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  nix.settings.allowed-users = lib.mkDefault ["@users"];

  services.dbus.apparmor = "enabled";

  security.apparmor.enable = lib.mkDefault true;
  security.apparmor.killUnconfinedConfinables = lib.mkDefault true;

  security.sudo.execWheelOnly = true;

  services.fail2ban.enable = true;

  sops.age.keyFile =
    if (builtins.hasAttr "persistence" config.environment)
    then "/persist/var/lib/sops-nix/key.txt"
    else "/var/lib/sops-nix/key.txt";

  # We place down a empty file just so we can test and workaround
  # the fact that we don't actually have default secrets
  sops.defaultSopsFile = ./.sops.yaml;
}
