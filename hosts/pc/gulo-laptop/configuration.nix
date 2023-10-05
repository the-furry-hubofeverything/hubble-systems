{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];
  # === HARDWARE SPECIFIC CONFIG ===
  hardware.bluetooth.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  # Firmware update for devices (USB, UEFI, SSD etc.)
  services.fwupd.enable = true;

  boot.kernelParams = [
  ];

  hardware.acpilight.enable = true;

  # --- amdgpu options ---
  hardware.amdgpu = {
    # Early KMS
    loadInInitrd = true;
    # OpenCL runtimes
    opencl = true;
  };

  # --- nvidia options ---
  hardware.nvidia = {
    # Fix screen tearing under PRIME
    modesetting.enable = true;
    # Use open source kernel module
    open = true;
  };

  # Gaming gpu power thing
  programs.gamemode.settings.gpu = {
    apply_gpu_optimisations = "accept-responsibility";
    nv_powermizer_mode = 1;
  };

  # HIP workaround
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  ];

  # === SYSTEM CONFIG ===
  networking.hostName = "Gulo-Laptop"; # Define your hostname.

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.initrd.systemd.enable = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-1dca9a74-a2da-4d8d-b64a-80f2f0f82101".device = "/dev/disk/by-uuid/1dca9a74-a2da-4d8d-b64a-80f2f0f82101";
  boot.initrd.luks.devices."luks-1dca9a74-a2da-4d8d-b64a-80f2f0f82101".keyFile = "/crypto_keyfile.bin";

  # Enable networking
  networking.networkmanager.enable = true;

  # Kernel selection and modules
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModulePackages = with config.boot.kernelPackages; [x86_energy_perf_policy];
  boot.kernelModules = [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion.
  system.stateVersion = "23.05"; # Did you read the comment?
}
