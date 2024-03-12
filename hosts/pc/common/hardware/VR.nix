{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    unstable.monado
    unstable.opencomposite
  ];

  nixpkgs.xr.enable = true;
}