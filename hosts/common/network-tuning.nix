_: {
  boot.kernel.sysctl = {
    "net.ipv4.tcp_fastopen" = 3;

    # BDP calculations
    # the optimal buffer size should be twice the BDP.
    # Since ping is already rtt, and rtt is 2 * delay,
    # the optimal buffer size is bandwidth * rtt.
    # https://fasterdata.es.net/host-tuning/background/

    # allow buffers up to 16MB
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;

    # For UDP, buffer size is not related to RTT the way TCP is,
    # but the defaults are still not large enough. Setting the
    # socket buffer to 4M seems to help a lot in most cases
    # https://fasterdata.es.net/host-tuning/linux/udp-tuning/
    "net.core.rmem_default" = 4194304;
    "net.core.wmem_default" = 4194304;

    # worst case - 220 ms, 300mbps = 8.25 mb = 8250000
    # best case - 0.8 ms, 1 gbps = 0.01 mb = 100000
    # average - 250mb per hour, 15ms, 55kbps = 1040
    "net.ipv4.tcp_rmem" = "1024 131072 8650752";
    "net.ipv4.tcp_wmem" = "1024 131072 8650752";

    # Under certain, BBR may retry more packets because
    # it doesn't consider packet loss as congestion. However,
    # it increases throughput when the buffer isn't constrained.
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  boot.kernelModules = ["tcp_bbr"];
}
