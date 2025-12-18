{lib, pkgs, ...}: {
  # CPU thermal
  services.thermald.enable = true;

  # kernel tweaks
  boot.kernel.sysctl = {
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;

    # musnix also sets this
    "vm.swappiness" = lib.mkDefault 10;
  };
  
  # Automatic nice daemon
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };
  
  boot.kernelParams = [
    # Switch to tsc (time stamp counter) at the cost of precision
    "tsc=reliable"
    "clocksource=tsc"

    # https://wiki.linuxaudio.org/wiki/system_configuration#do_i_really_need_a_real-time_kernel
    "threadirqs"
  ];
}
