{...}: {
  # CPU thermal
  services.thermald.enable = true;

  # kernel tweaks
  boot.kernel.sysctl = {
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.ipv4.tcp_fastopen" = 3;

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
