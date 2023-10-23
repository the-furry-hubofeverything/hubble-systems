{
  inputs,
  config,
  pkgs,
  lib,
  fetchurl,
  ...
}: let
  fabricServerOptimizations = pkgs.fetchPackwizModpack {
    url = "https://github.com/the-furry-hubofeverything/fabric-server-optimizations/raw/a4d9559ceeac6657443f21a599ce7d22e080ad6f/pack.toml";
    packHash = "sha256-E/kChdScTNEuonlswl59T1U7LdJ9iADMfWSQJs+oqUk=";
  };
  fanesTrainShenanigans = pkgs.fetchPackwizModpack {
    url = "https://github.com/the-furry-hubofeverything/fanes-train-shenanigans/raw/599f90a85c95e43b4631d1b5221e8e57bf6ab816/pack.toml";
    packHash = "sha256-MOyP6/X3Mwl4ONX7DZJYM+0pu3wPKiBYsMFdF6SoaWE=";
  }; 

  modpack = fabricServerOptimizations.addFiles {
    "" = "${fanesTrainShenanigans}/mods";
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
        jvmOpts = "-Xmx8G -Xms1G";

        serverProperties = {
          gamemode = "creative";
          motd = "Attention Everyone, Blue Line Trains are NOT RUNNING; Please use ORANGE LINE TRAINS";
          spawn-monsters = false;
          white-list = true;
          server-port = 25566;
          view-distance = 16;

          op-permission-level = 2;
        };

        symlinks = {
          "mods" = "${modpack}/mods";
        };
      };
    };
  };
}
