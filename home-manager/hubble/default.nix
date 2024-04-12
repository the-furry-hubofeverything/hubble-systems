# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.git-credential-oauth
    ./obs.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      inputs.nixd.overlays.default

      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stacked

      inputs.blender-bin.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for home-manager #2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "hubble";
    homeDirectory = "/home/hubble";
    stateVersion = "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    packages = with pkgs; [
      # dev packages
      nixpkgs-fmt
      nixd
      sops

      easyeffects

      inkscape
    ] ++ [
      # To be replaced when upgraded 23.11
      pkgs.blender_3_6
      pkgs.unstable.xwaylandvideobridge
    ];

    pointerCursor = {
      name = "Wii-Pointer";
      package = pkgs.wii-pointer;
      gtk.enable = true;
      x11.enable = true;
    };
  };

  # Enable home-manager and git
  programs = {
    home-manager.enable = true;

    vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
    git = {
      enable = true;
      package = pkgs.gitFull;
      userEmail = "hubblethewolverine@gmail.com";
      userName = "the-furry-hubofeverything";
      extraConfig = {
        # Remember to run `git maintenance start`
        core.autocrlf = "input";
        http.postBuffer = "524288000";
        branch.sort = "-committerdate";
        gpg.format = "ssh";

        # Automatically resolve merge conflicts with recorded fix
        rerere.enabled = true;
        # Improve log ops for large repos
        fetch.writeCommitGraph = true;
        # Make refs for pull requests
        remote.origin.fetch = "+refs/pull/*:refs/remotes/origin/pull/*";
      };
    };
  };

  # Bluetooth Media controls
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = ["network.target" "sound.target"];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = ["default.target"];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
