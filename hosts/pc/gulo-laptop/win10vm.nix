{
  config,
  pkgs,
  ...
}: {
  boot.kernelParams = [
    "amd_iommu=on"
    "pcie_acs_override=id:1022:1639,multifunction,downstream"
  ];

  boot.kernelModules = [
    "kvm-amd"
  ];

  boot.blacklistedKernelModules = [
    "i2c_nvidia_gpu"
  ];

  # Temporary fix to https://github.com/NixOS/nixpkgs/issues/51152, to be changed when libvirtd.hookModule is implemented
  # TODO migrate to a more paramatric form instead a WHOLLLE script
  systemd.services.libvirtd.preStart = let
    qemuHook = pkgs.writeScript "qemu-hook" ''
      #!${pkgs.stdenv.shell}

      GUEST_NAME="$1"
      OPERATION="$2"
      SUB_OPERATION="$3"

      if [ "$GUEST_NAME" == "win10" ]; then
        if [ "$OPERATION" == "prepare" ]; then
          if [ $(/run/current-system/sw/bin/supergfxctl -g) != "Integrated" ]; then
            echo "Must be in integrated mode"
            exit 1
          fi

          /run/current-system/sw/bin/supergfxctl -m "Vfio"

          while [ $(/run/current-system/sw/bin/supergfxctl -g) != "Vfio" ]; do
            sleep 1
          done

          modprobe -r --remove-holder nvidia_drm
          modprobe -r --remove-holder nvidia_uvm
          modprobe -r --remove-holder nvidia_modeset
          modprobe -r --remove-holder nvidia

          virsh nodedev-detach pci_0000_01_00_0
          virsh nodedev-detach pci_0000_01_00_1
          virsh nodedev-detach pci_0000_01_00_2
          virsh nodedev-detach pci_0000_01_00_3

          virsh nodedev-detach pci_0000_07_00_3

          systemctl set-property --runtime -- init.scope AllowedCPUs=0-5
          systemctl set-property --runtime -- user.slice AllowedCPUs=0-5
          systemctl set-property --runtime -- system.slice AllowedCPUs=0-5
        fi

        # if [ "$OPERATION" == "started" ]; then
        #   dhcpcd -n virbr0
        # fi

        if [ "$OPERATION" == "stopped" ]; then
          /run/current-system/sw/bin/supergfxctl -m "Integrated"

          virsh nodedev-reattach pci_0000_01_00_0
          virsh nodedev-reattach pci_0000_01_00_1
          virsh nodedev-reattach pci_0000_01_00_2
          virsh nodedev-reattach pci_0000_01_00_3

          virsh nodedev-reattach pci_0000_07_00_3

          systemctl set-property --runtime -- init.scope AllowedCPUs=0-15
          systemctl set-property --runtime -- user.slice AllowedCPUs=0-15
          systemctl set-property --runtime -- system.slice AllowedCPUs=0-15


          modprobe nvidia
          modprobe nvidia_drm
          modprobe nvidia_uvm
          modprobe nvidia_modeset
        fi
      fi
    '';
  in ''
    mkdir -p /var/lib/libvirt/hooks
    chmod 755 /var/lib/libvirt/hooks

    # Copy hook files
    ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
  '';

  virtualisation.libvirtd.allowedBridges = [
    "virbr0"
    "virbr1"
  ];

  # SMB for second drive
  # TODO secure SMB
  services.samba = {
    enable = true;
    extraConfig = ''
      hosts_allow = 192.168.100.0/24, localhost, 127.0.0.1
      writeable = Yes

      read raw = Yes
      write raw = Yes
      max xlimit = 65535
      socket options = TCP_NODELAY
      SO_RCVBUF = 65536
      SO_SNDBUF = 65536
      min protocol = smb2
      deadtime = 15
    '';
    shares = {
      Data = {path = "/run/media/hubble/Data";};
    };
    openFirewall = true;
  };
}
