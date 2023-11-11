{
  inputs,
  config,
  pkgs,
  lib,
  fetchurl,
  ...
}: let
  owner = config.services.minecraft-servers.user;
  group = config.services.minecraft-servers.group;

  fabricServerOptimizations = pkgs.fetchPackwizModpack {
    url = "https://github.com/the-furry-hubofeverything/fabric-server-optimizations/raw/f88e977440507469023fc9836aaf245e71bf802f/pack.toml";
    packHash = "sha256-bd/bzEMiryRP6yp2A126KweBw+LvdoZ4ijHh91WrMmQ=";
  };
  fanesTrainShenanigans = pkgs.fetchPackwizModpack {
    url = "https://github.com/the-furry-hubofeverything/fanes-train-shenanigans/raw/8a569e29b44a36d63a4f46eb373477b524091fd2/pack.toml";
    packHash = "sha256-wHgS3JJlTiSesYuKdXDm0hcUepTO2gXSp4b0vqqmJEA=";
  };

  modpack = fabricServerOptimizations.addFiles {
    "" = "${fanesTrainShenanigans}/mods";
  };

  jvmOptimizationFlags = ''
    --add-modules=jdk.incubator.vector \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    '';
in {
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  sops.secrets.minecraft-SMP-whitelist = {
    inherit owner group;
  };

  sops.secrets.minecraft-creative-whitelist = {
    inherit owner group;
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers = {
      "SMP" = {
        enable = true;
        package = pkgs.paperServers.paper;
        jvmOpts = jvmOptimizationFlags;

        serverProperties = {
          gamemode = "survival";
          motd = "Hub's chill survival place thing";
          difficulty = "hard";
          white-list = true;

          op-permission-level = 1;
        };

        symlinks = {
          "whitelist.json" = config.sops.secrets.minecraft-SMP-whitelist.path;
        };
      };

      "creative" = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_19_4;
        jvmOpts = jvmOptimizationFlags + "-Xmx8G -Xms8G";

        serverProperties = {
          gamemode = "creative";
          motd = "Attention Everyone, Blue Line Trains are NOT RUNNING; Please use ORANGE LINE TRAINS";
          spawn-monsters = false;
          white-list = true;
          server-port = 25566;
          sync-chunk-writes = false;
          simulation-distance = 6;
          network-compression-threshold = 256;
          enable-command-block = true;

          op-permission-level = 2;
        };

        symlinks = {
          "mods" = "${modpack}/mods";
          "whitelist.json" = config.sops.secrets.minecraft-creative-whitelist.path;
        };
      };
    };
  };
  environment.persistence."/persist" = {
    directories = [
      (config.services.minecraft-servers.dataDir)
    ];
  };

  services.nginx.virtualHosts."${config.networking.hostName}.gulo.dev" = lib.optionalAttrs (config.services.minecraft-servers.servers."creative".enable) {
    locations."/mtr-map/" = {
      proxyPass = "http://127.0.0.1:8888/";
      extraConfig =
        "proxy_set_header Host $host;" +
        # required when the target is also TLS server with multiple hosts
        "proxy_ssl_server_name on;";
    };
  };
}
