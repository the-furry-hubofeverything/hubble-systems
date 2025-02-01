{
  pkgs,
  lib,
  ...
}: {
  # Not needed as it's handled in home-manager
  environment.systemPackages = with pkgs; [
    nurl
    nix-output-monitor
  ];

  programs.ccache.enable = true;
  boot.binfmt.emulatedSystems = lib.optionals (pkgs.system != "aarch64-linux") ["aarch64-linux"];
}
