{
  inputs,
  config,
  pkgs,
  lib,
  fetchurl,
  ...
}: let
  fabricServerOptimizations =
    (pkgs.fetchPackwizModpack {
      url = "https://github.com/the-furry-hubofeverything/fabric-server-optimizations/raw/1.19.4/pack.toml";
      packHash = "sha256-E/kChdScTNEuonlswl59T1U7LdJ9iADMfWSQJs+oqUk=";
    })
    .addFiles {
      # transtion to packwiz eventually
      "mods/minecraftTransitRailway.jar" = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/XKPAmI6u/versions/PP5puu9Z/MTR-forge-1.19.4-3.2.2-hotfix-1.jar";
        sha512 = "ebd61018b4e9adc6fd097965b5dadc688415d688b0ddeddd2ba21457da3f0104d5fff161373df1a2bb76fc1c458f39f20dce9ab8bf44bc7ac35a30f5f9d49442";
      };

      "mods/stationDecoration.jar" = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/AM3NyLOZ/versions/uckw2Zw0/MTR-MSD-Addon-fabric-1.19.4-3.2.2-1.3.4-enhancement-1.jar";
        sha512 = "63047bc0b7168888a2cecad59f352b02ad07153566ed3f6227728aaf25f50617afc65b91a4464cfda799204e56e30d239468b1a9261272279c59e6fde24a292d";
      };

      # MTR dependency
      "mods/fabricAPI.jar" = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/uIYkhRbX/fabric-api-0.86.1%2B1.19.4.jar";
        sha512 = "5e69f86026180244508ef4941433cb2b5821463e3e5d7f85a2eadb976a03b1ca25e6edc3337aa9d34ef6ed96e07cdf8f5a00261a97798afe08263ca692546c0d";
      };
    };
in {
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    # Uses persist folder
    # TODO migrate to impermanence
    dataDir = "/persist/minecraft";
    servers = {
      "SMP" = {
        enable = true;
        package = pkgs.paperServers.paper;

        # TODO declarative whitelist
        serverProperties = {
          gamemode = "survival";
          motd = "Hub's chill survival place thing";
          difficulty = "hard";
          white-list = true;

          op-permission-level = 1;
        };
      };

      "creative" = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_19_4;

        serverProperties = {
          gamemode = "creative";
          motd = "Fane's building place thing";
          spawn-monsters = false;
          white-list = true;
          server-port = 25566;

          op-permission-level = 2;
        };

        symlinks = {
          "mods" = "${fabricServerOptimizations}/mods";
        };
      };
    };
  };
}
