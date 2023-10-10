{
  inputs,
  config,
  pkgs,
  ...
}: {
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
        enable = false;
        package = pkgs.fabricServers.fabric-1_19_3;

        serverProperties = {
          gamemode = "creative";
          motd = "Fane's building place thing";
          spawn-monsters = false;
          white-list = true;

          op-permission-level = 2;
        };

        symlinks = {
        };
      };
    };
  };
}
