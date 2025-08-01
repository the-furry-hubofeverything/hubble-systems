# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  hs-utils,
  config,
  pkgs,
  ...
}: {
  assertions = [
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "security: defaultSopsFile not empty, cannot continue";
    }
  ];
  # You can import other home-manager modules here
  imports = [
    outputs.homeManagerModules.git-credential-oauth
    inputs.sops-nix.homeManagerModules.sops
    inputs.hs-secrets.homeManagerModules.hubble
    ./obs.nix
    ./vr.nix
    ./niri.nix
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../hosts/common/.sops.yaml;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
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
      cudaSupport = true;
      rocmSupport = true;
    };
  };

  home = {
    username = "hubble";
    homeDirectory = "/home/hubble";
    stateVersion = "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    packages =
      (with pkgs; [
        # dev packages for hubble-systems
        sops
        alejandra

        easyeffects

        signal-desktop

        inkscape
        element-desktop
        kdePackages.xwaylandvideobridge

        gnome-calculator
        gnome-disk-utility
        loupe

        libreoffice-qt
        anki-bin

        hunspell
        hunspellDicts.en_CA-large
      ])
      ++ [
        inputs.muse-sounds-manager.packages.${pkgs.system}.muse-sounds-manager
        pkgs.unstable.musescore

        # To be replaced when upgraded 23.11
        pkgs.blender_3_6

        # nix dev stuff
        pkgs.nixpkgs-fmt
        inputs.nixd.packages.${pkgs.system}.nixd

        pkgs.unstable.vintagestory

        # TODO replace with programs.rclone for 25.05
        pkgs.rclone
        pkgs.unstable.kopia
        pkgs.unstable.kopia-ui
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

    ssh = {
      enable = true;
      matchBlocks."git@alex.gulo.dev" = {
        match = "Host alex.gulo.dev User git";
        identityFile = "/home/hubble/.ssh/id_hs-secrets";
      };
    };

    # rclone = {
    #   enable = true;
    #   remotes = {
    #     enterprise.config = {
    #       type = "sftp";
    #       host = "enterprise.nebula.gulo.dev";
    #       user = "kopia";
    #       keyFile = "${config.home.homeDirectory}/.ssh/id_kopia";
    #     };

    #     b2 = {
    #       config = {
    #         type = "b2";
    #       };

    #       secrets = {
    #         account = config.sops.secrets.b2ID.path;
    #         key = config.sops.secrets.b2Key.path;
    #       };
    #     };
    #   };
    # };

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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-chinese-addons
      ];
      waylandFrontend = true;
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
