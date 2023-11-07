{
  inputs,
  hs-utils,
  config,
  pkgs,
  lib,
  fetchurl,
  ...
}: let
  fanesTrainShenanigans = pkgs.fetchPackwizModpack {
    url = "https://github.com/the-furry-hubofeverything/fanes-train-shenanigans/raw/fd092b884611cf17594cc57b39b8867788f838a7/pack.toml";
    packHash = "sha256-maxrc3JbI0OpXY7LlevJrulbvVveJvWML7Q512GPeZU=";
  };

  optimizeServerModpack = modpack: pname: version: pkgs.stdenvNoCC.mkDerivation {
    inherit pname version;

    src = pkgs.fetchPackwizModpack {
      url = "https://github.com/the-furry-hubofeverything/fabric-server-optimizations/raw/f88e977440507469023fc9836aaf245e71bf802f/pack.toml";
      packHash = "sha256-bd/bzEMiryRP6yp2A126KweBw+LvdoZ4ijHh91WrMmQ=";
    };

    inputs = [ modpack ];

    dontUnpack = true;
    dontConfig = true;
    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall

      mkdir -p $out/mods
      cp -sr "$src/mods" "${modpack}/mods/" $out/

      runHook postInstall
    '';
  };

  # https://flags.sh/
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
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${config.networking.hostName}.gulo.dev";
      message = "minecraftServers: ${config.networking.hostName}.gulo.dev is undefinied, this depends on acme-nginx-rp.nix";
    }
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "minecraftServers: defaultSopsFile not empty, cannot continue";
    }
    {
      assertion = !hs-utils.sops.isDefault config.sops "minecraft-SMP-whitelist";
      message = "minecraftServers: SMP server whitelist secret not defined";
    }
    {
      assertion = !hs-utils.sops.isDefault config.sops "minecraft-creative-whitelist";
      message = "minecraftServers: Creative server whitelist secret not defined";
    }
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  # Set ownership for whitelist sops files
  # whitelist secrets must be name "minecraft-{name}-whitelist"
  sops.secrets = lib.mapAttrs' (
    serverName: server: {
      name = "minecraft-${serverName}-whitelist";
      value = lib.optionalAttrs server.serverProperties.white-list {
        inherit (config.services.minecraft-servers) group;
        owner = config.services.minecraft-servers.user;
      };
    }
  ) config.services.minecraft-servers.servers;

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
        enable = false;
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
          "mods" = "${optimizeServerModpack fanesTrainShenanigans "fanes-train-shenanigans" "unstable-1.0"}/mods";
          "whitelist.json" = config.sops.secrets.minecraft-creative-whitelist.path;
        };
      };
    };
  };

  services.nginx.virtualHosts."${config.networking.hostName}.gulo.dev" = lib.optionalAttrs (config.services.minecraft-servers.servers."creative".enable) {
    locations."/mtr-map/" = {
      proxyPass = "http://127.0.0.1:8888/";
      extraConfig =
        "proxy_set_header Host $host;"
        +
        # required when the target is also TLS server with multiple hosts
        "proxy_ssl_server_name on;";
    };
  };
}
