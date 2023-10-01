{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs.unstable; [
    git-credential-oauth
  ];

  programs.git.extraConfig.credential.helper = ["${pkgs.unstable.git-credential-oauth}/bin/git-credential-oauth"];
}
