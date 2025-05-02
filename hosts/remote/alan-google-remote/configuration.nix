{
  lib,
  inputs,
  ...
}: {
  imports = [
    "${inputs.nixpkgs.sourceInfo.outPath}/nixos/modules/virtualisation/google-compute-image.nix"
  ];

  sops.age.sshKeyPaths = [];

  # https://github.com/NixOS/nixpkgs/issues/218813
  security.googleOsLogin.enable = lib.mkForce false;

  # I don't like the default
  networking.firewall.enable = true;

  networking.hostName = "alan-google-remote";
  system.stateVersion = "23.11";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
