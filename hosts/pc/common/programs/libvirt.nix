# Modified from https://pastebin.com/q3RQZYUS, originally https://www.reddit.com/r/VFIO/comments/p4kmxr/tips_for_single_gpu_passthrough_on_nixos/
# With bits from https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
{
  config,
  pkgs,
  lib,
  outputs,
  ...
}: {
  # Boot configuration
  boot.kernelParams = [
    "vfio_iommu_type1.allow_unsafe_interrupts=1"
    "kvm.ignore_msrs=1"
    "vfio-pci.disable_idle_d3=1"
    "usbcore.autosuspend=-1"
    "preempt=voluntary"
  ];

  boot.kernelModules = [
    "mdev"
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    (lib.optionalString (lib.versionOlder config.boot.kernelPackages.kernel.version "6.2") "vfio_virqfd")
  ];

  # Fix bridge interface stopping
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="module", KERNEL=="br_netfilter", RUN+="${pkgs.systemd}/lib/systemd/systemd-sysctl --prefix=net/bridge"
  '';
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-ip6tables" = 0;
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-arptables" = 0;
  };

  # User accounts
  users.users.hubble = {
    extraGroups = ["libvirtd"];
  };

  boot.extraModprobeConfig = "options vfio_iommu_type1.allow_unsafe_interrupts=1 softdep xhci_hcd";

  virtualisation.libvirtd.extraConfig = "max_client_requests = 25 \nmax_clients = 100 \nmax_requests = 100";

  programs.virt-manager.enable = true;

  # Enable libvirtd
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull.fd]; # Windows 11 secure boot support https://github.com/NixOS/nixpkgs/issues/164064
      };
      swtpm.enable = true;
      runAsRoot = true;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  networking.dhcpcd.denyInterfaces = ["macvtap0@*"];

  networking.networkmanager.unmanaged = [
    "virbr0"
  ];

  # VFIO Packages installed
  environment.systemPackages = with pkgs; [
    virtiofsd
    libguestfs # needed to virt-sparsify qcow2 files
    looking-glass-client
  ];

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 hubble libvirtd -"
  ];
}
