{
  pkgs,
  lib,
  ...
}: {
  boot.kernelParams = [
    "amd_iommu=on"
    "pcie_acs_override=id:1022:1639,multifunction,downstream"

    # amdgpu related workaround for vfio memory shenanigans.

    # Aug 20 21:58:10 Gulo-Laptop kernel: x86/PAT: CPU 0/KVM:7808 conflicting memory types b0000000-c0000000 write-combining<->uncached-minus
    # Aug 20 21:58:10 Gulo-Laptop kernel: x86/PAT: memtype_reserve failed [mem 0xb0000000-0xbfffffff], track uncached-minus, req uncached-minus
    # Aug 20 21:58:10 Gulo-Laptop kernel: ioremap memtype_reserve failed -16

    # Source:
    # https://www.reddit.com/r/VFIO/comments/xt5cdm/dmesg_shows_thousands_of_these_errors_ioremap/
    # ioremap error workaround
    "NVreg_UsePageAttributeTable=1"
  ];

  boot.kernelModules = [
    "kvm-amd"
  ];

  virtualisation.libvirtd = {
    allowedBridges = [
      "virbr0"
      "virbr1"
    ];

    hooks = {
      qemu."supergfx-nvidia-hybrid-graphics-switch" = let
        vmName = "win10";

        pciDevices = [
          # GPU
          "pci_0000_01_00_0"
          "pci_0000_01_00_1"
          "pci_0000_01_00_2"
          "pci_0000_01_00_3"

          # USB-C
          "pci_0000_07_00_3"
        ];
      in
        lib.getExe (pkgs.writeShellApplication {
          name = "qemu-hook";

          runtimeInputs = with pkgs; [
            libvirt
            kmod
            systemd
            supergfxctl
            libnotify
          ];

          text = ''
            GUEST_NAME="$1"
            OPERATION="$2"
            # SUB_OPERATION="$3"

            if [ "$GUEST_NAME" == "${vmName}" ]; then
              if [ "$OPERATION" == "prepare" ]; then
                if [ "$(supergfxctl -g)" != "Integrated" ]; then
                  notify-send "Libvirt error" "Hybrid graphics be in integrated mode" -u critical
                  exit 1
                fi

                supergfxctl -m "Vfio"

                while [ "$(supergfxctl -g)" != "Vfio" ]; do
                  sleep 1
                done

                modprobe -r --remove-holder nvidia_drm
                modprobe -r --remove-holder nvidia_uvm
                modprobe -r --remove-holder nvidia_modeset
                modprobe -r --remove-holder nvidia

                ${lib.strings.concatMapStringsSep "\n    " (x: "virsh nodedev-detach " + x) pciDevices}

                systemctl set-property --runtime -- init.scope AllowedCPUs=0-5
                systemctl set-property --runtime -- user.slice AllowedCPUs=0-5
                systemctl set-property --runtime -- system.slice AllowedCPUs=0-5
              fi

              if [ "$OPERATION" == "stopped" ]; then
                if [ "$(supergfxctl -g)" != "Vfio" ]; then
                  notify-send "Libvirt error" "Critical error (unexpected graphics mode)" -u critical
                  exit 1
                fi
                supergfxctl -m "Integrated"

                ${lib.strings.concatMapStringsSep "\n    " (x: "virsh nodedev-reattach " + x) pciDevices}

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
        });
    };
  };

  # SMB for second drive
  services.samba = {
    enable = true;
    settings = {
      global = {
        "interfaces" = ["virbr1" "lo"];
        "bind interfaces only" = "yes";

        # Don't hide dot files - same behavior for windows, prevents Unity/VCC shenanigans
        # ie. VRChat Creator Companion error "Access to the '[...]\Packages\.gitignore' is denied."
        "hide dot files" = "No";

        "read raw" = "yes";
        "write raw" = "yes";
        "use sendfile" = "yes";
        "socket options" = ["IPTOS_LOWDELAY" "TCP_NODELAY" "IPTOS_THROUGHPUT"];
        "min protocol" = "smb2";
        "deadtime" = 30;

        "server smb encrypt" = "desired";
      };
    };
    shares = {
      Data = {
        path = "/run/media/hubble/Data";
        "read only" = "no";
        browsable = "yes";
      };
    };
    openFirewall = false;
  };
  # Workaround for interface specific "openFirewall"
  networking.firewall.interfaces."virbr1" = {
    allowedTCPPorts = [139 445];
    allowedUDPPorts = [137 138];
  };

  # VRChat firewall ports
  networking.firewall.interfaces."virbr0" = {
    allowedUDPPorts = [5055 5056 5058];
    allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27100;
      }
    ];
  };
}
