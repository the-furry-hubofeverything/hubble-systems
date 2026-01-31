# PC common configs
{
  inputs,
  lib,
  outputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc

    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr

    ./pc.nix
    ./gaming.nix
    ./performance-tweaks.nix
    ./security.nix
    ./wayland.nix
    ./audio.nix

    # ./desktop-environments/gnome.nix
    ./desktop-environments/niri.nix

    ./hardware/logitechWheelSupport.nix
    ./hardware/VR.nix

    ./programs/kdeconnect.nix
    ./programs/lanzaboote.nix
    ./programs/libvirt.nix
    ./programs/libvirt-win10vm.nix
    ./programs/nix-alien.nix
    ./programs/ollama.nix

    ../../common/security.nix
    ../../common/nix-settings.nix
    ../../common/development.nix
    ../../common/hubbleGroups.nix
    ../../common/bash-config.nix
    ../../common/network-tuning.nix

    ../../common/dhcp-ntp.nix

    # outputs.nixosModules.flamenco
    # ../../common/services/flamenco.nix

    ../../common/services/nebula.nix
    ../../common/services/monitoring.nix

    # ../../common/filesystems/zfs.nix
  ];

  boot.loader.systemd-boot.configurationLimit = 3;

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";
  i18n.supportedLocales = [
    #    "en_CA.UTF-8/UTF-8"
    #    "zh_CN.UTF-8/UTF-8"
    "all"
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nix = {
    settings = {
      substituters = [
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
    buildMachines = [
      {
        hostName = "nixremote@enterprise.nebula.gulo.dev";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        # default is 1 but may keep the builder idle in between builds
        maxJobs = 8;
        # how fast is the builder compared to your local machine
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
      {
        hostName = "nixremote@titan.nebula.gulo.dev";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        # default is 1 but may keep the builder idle in between builds
        maxJobs = 4;
        # how fast is the builder compared to your local machine
        speedFactor = 1;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
      {
        hostName = "nixremote@alex.nebula.gulo.dev";
        system = "aarch64-linux";
        protocol = "ssh-ng";
        # default is 1 but may keep the builder idle in between builds
        maxJobs = 4;
        # how fast is the builder compared to your local machine
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
    ];
    distributedBuilds = true;
  };

  # For rquickshare in home-manager
  networking.firewall.allowedTCPPorts = [ 30609 ];

  programs.ssh.extraConfig = ''
    Match Host *.nebula.gulo.dev User nixremote
      IdentityFile /home/hubble/.ssh/id_nixremote
  '';

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
