{
  inputs,
  outputs,
  lib,
  ...
}: {
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stacked
    ];
    config = {
      allowUnfree = true;
      cudaSupport = true;
      rocmSupport = true;
    };
  };

  nix = let
    # Filter non-flake inputs for the next two functions
    flakes = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakes;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (x: _: "${x}=flake:${x}") flakes;

    settings = {
      # Enable flakes
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
    gc.automatic = true;
    # optional, useful when the builder has a faster internet connection than yours
    extraOptions = "builders-use-substitutes = true";
  };
}
