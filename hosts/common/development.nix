{pkgs, ...}: {
  # Not needed as it's handled in home-manager
  environment.systemPackages = with pkgs; [
    (nurl.overrideAttrs (_: prev: {
      patches = prev.patches ++ [
        ./nurl-flake.patch
      ];
    }))
    nix-output-monitor
  ];

  programs.ccache.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
