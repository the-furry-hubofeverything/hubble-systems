{
  inputs,
  config,
  pkgs,
  lib,
  fetchurl,
  ...
}: let
  fabricServerOptimizations = pkgs.fetchPackwizModpack {
    url = "https://github.com/the-furry-hubofeverything/fabric-server-optimizations/raw/1.19.4/pack.toml";
    packHash = "sha256-E/kChdScTNEuonlswl59T1U7LdJ9iADMfWSQJs+oqUk=";
  };
  fanesTrainShenanigans = pkgs.fetchPackwizModpack {
    url = "https://github.com/the-furry-hubofeverything/fanes-train-shenanigans/raw/master/pack.toml";
    packHash = "sha256-t6yx7AOCHhznxqLylvropviLEg1B9Vt7gJt/e1sg/zY=";
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
