{
  pkgs,
  lib,
  config,
  ...
}: {
  # Not needed as it's handled in home-manager
  environment.systemPackages = with pkgs; [
    nurl
    nix-output-monitor
  ];

  programs.ccache.enable = true;
  boot.binfmt.emulatedSystems = lib.optionals (config.nixpkgs.hostPlatform != "aarch64-linux") ["aarch64-linux"];
}
