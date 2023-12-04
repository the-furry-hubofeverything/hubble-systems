{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];
}