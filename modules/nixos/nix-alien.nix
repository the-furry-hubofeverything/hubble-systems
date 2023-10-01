{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.nix-alien.packages.${pkgs.system}.default
  ];

  programs.nix-ld.enable = true;
}
