{
  config,
  pkgs,
  ...
}: {
  # k3s, define roles in machine specific config
  networking.firewall.allowedTCPPorts = [6443];
  services.k3s.enable = true;
  services.k3s.extraFlags = toString [
    # Optionally add additional args to k3s
  ];
  environment.systemPackages = [pkgs.k3s];
}
