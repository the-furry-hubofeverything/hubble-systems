{ pkgs, ... }: {
  # TODO develop module
  environment.systemPackages = [ pkgs.sheepit-client ];
}