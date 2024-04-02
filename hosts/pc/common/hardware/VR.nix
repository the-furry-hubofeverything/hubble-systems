{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    monado
    opencomposite
  ];

  nixpkgs.xr.enable = true;
}