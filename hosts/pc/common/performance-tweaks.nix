{...}: {
  # CPU thermal
  services.thermald.enable = true;

  # kernel tweaks
  programs.cfs-zen-tweaks.enable = true;
  boot.kernel.sysctl = {
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.log_martians" = 1;

    "vm.swappiness" = 10;

    # Allow emergency sysrq reboot "reisub"
    "kernel.sysrq" = 246;
  };

  # Distribute irq over multiple cores
  services.irqbalance.enable = true;

  # Automatic nice daemon
  services.ananicy.enable = true;

  # Switch to tsc (time stamp counter) at the cost of precision
  boot.kernelParams = ["tsc=reliable" "clocksource=tsc"];
}
