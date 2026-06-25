{
  inputs,
  hs-utils,
  config,
  pkgs,
  lib,
  ...
}: let
  guloIndPack = pkgs.fetchModrinthModpack {
    url = "https://github.com/the-furry-hubofeverything/gulo-industries-pack/releases/download/v2.0.1/Gulo.Industries-2.0.1.mrpack";
    packHash = "sha256-pTMzZmuluVJ2EEsS/h0V/2AdA4WsTvqvoaW6z0uZ7sU=";
    side = "server";
  };

  jvmOptimizationFlags = ''
    -XX:+UseZGC \
    -XX:-ZProactive \
    -XX:+UnlockExperimentalVMOptions \
    -Dterminal.jline=false \
    -Dterminal.ansi=true \
    -Djline.terminal=jline.UnsupportedTerminal \
    -Dlog4j2.formatMsgNoLookups=true \
    -XX:+DisableExplicitGC \
    -XX:+UseNUMA \
    -XX:NmethodSweepActivity=1 \
    -XX:ReservedCodeCacheSize=400M \
    -XX:NonNMethodCodeHeapSize=12M \
    -XX:ProfiledCodeHeapSize=194M \
    -XX:NonProfiledCodeHeapSize=194M \
    -XX:+PerfDisableSharedMem \
    -XX:+EagerJVMCI \
    -XX:+ParallelRefProcEnabled \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:SurvivorRatio=32 \
    -XX:MaxTenuringThreshold=1 \
    -XX:+UseStringDeduplication \
    -XX:+UseAES \
    -XX:+UseFMA \
    -XX:+AlwaysPreTouch \
    -XX:+UseTransparentHugePages \
    -XX:+UseLargePages \
    -XX:+UseLoopPredicate \
    -XX:+RangeCheckElimination \
    -XX:+EliminateLocks \
    -XX:+DoEscapeAnalysis \
    -XX:+UseCodeCacheFlushing \
    -XX:+SegmentedCodeCache \
    -XX:+UseFastJNIAccessors \
    -XX:+OptimizeStringConcat \
    -XX:+UseCompressedOops \
    -XX:+UseThreadPriorities \
    -XX:+OmitStackTraceInFastThrow \
    -XX:ThreadPriorityPolicy=1 \
    -XX:+UseInlineCaches \
    -XX:+RewriteBytecodes \
    -XX:+RewriteFrequentPairs \
    -XX:-DontCompileHugeMethods \
    -XX:+UseFPUForSpilling \
    -XX:AllocatePrefetchStyle=3 \
    -XX:+UseFastStosb \
    -XX:+UseNewLongLShift \
    -XX:+UseVectorCmov \
    -XX:+UseXMMForArrayCopy \
    -XX:+UseXmmI2D \
    -XX:+UseXmmI2F \
    -XX:+UseXmmLoadAndClearUpper \
    -XX:+UseXmmRegToRegMoveAll \
    -XX:+UseLargePages \
    -XX:LargePageSizeInBytes=2M \
    -Dfile.encoding=UTF-8 \
    -Xlog:async \
    -Djava.security.egd=file:/dev/urandom \
    --add-modules jdk.incubator.vector
  '';
in {
  assertions = [
    {
      assertion = config.services.nginx.enable && config.services.nginx.virtualHosts ? "${lib.head (lib.splitString "-" config.networking.hostName)}.nebula.gulo.dev";
      message = "minecraftServers: ${lib.head (lib.splitString "-" config.networking.hostName)}.nebula.gulo.dev is undefinied, this depends on acme-nginx-rp.nix";
    }
    {
      assertion = hs-utils.sops.defaultIsEmpty config.sops;
      message = "minecraftServers: defaultSopsFile not empty, cannot continue";
    }
  ];

  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers = {
      "guloInd" = {
        enable = true;
        jvmOpts = "-Xms8G -Xmx12800M\ " + jvmOptimizationFlags;
        package = pkgs.neoforgeServers.neoforge-1_21_1;
        serverProperties = {
          allow-flight = true;
          difficulty = "normal";
          bug-report-link = "https://bsky.app/profile/hubofeverything.stormy.tf";
          enforce-secure-profile = false;
          enforce-whitelist = true;
          max-world-size = 2999998;
          motd = "§7from §r§6H§r§7+§r§3K§r§7 with <3§r";
          prevent-proxy-connections = true; # does it with vps-range anyway, might as well reinforce it
          view-distance = 6;
          simulation-distance = 8;
          spawn-protection = 0;
          whitelist = true;
        };
        symlinks = {
          "mods" = "${guloIndPack}/mods";
        };
        files = {
          "config" = "${guloIndPack}/config";
        };
      };
    };
  };

  services.nebula.networks."hsmn0".firewall.inbound =
    lib.optionals config.services.nebula.networks."hsmn0".enable
    [
      {
        port = "25565";
        proto = "tcp";
        group = ["remote"];
      }
    ];
}
