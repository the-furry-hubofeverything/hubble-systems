# Workarounds
All the jank in the hosts configuration.

As of Oct 24, 2023, not all workarounds may be documented. This line will be removed once I'm confident all workarounds are documented.

> [!IMPORTANT]
> These workarounds may not work after source flake updates. <br>
> When debugging, check workarounds first to see if the subjects debugged are affected.

> [!NOTE]
> If you are maintaining the flake that is relevant to the workaround, I would be happy to be included in the conversation.

## lcluster
### minecraftServer modpacks
There's currently no proper way to combine packwiz modpacks together. The two mods folder can't merge because both are read-only or something.
(I forgot to write it down)

Fabric server can't read mods in subdirectories. 

Since [`fetchPackwizModpack.addFiles`](https://github.com/Infinidoge/nix-minecraft/blob/2233b4c6d39623c89200b1e45e3ae920a9d7514a/pkgs/tools/fetchPackwizModpack/default.nix#L86) uses `mkdir` for making the dirs and `cp` for symlinks, might as well abuse it.

By setting the path to an empty string, we tell cp to copy directly into the mods folder, effectively merging both of them

```nix
  modpack = fabricServerOptimizations.addFiles {
    "" = "${fanesTrainShenanigans}/mods";
  };
```
## pc

### Networking issue (Gulo-Laptop)

`nixos-rebuild` will stay stuck when it's waiting for `NetworkManager-wait-online.service`. 

There's an issue for the stuck part (NixOS/nixpkgs#180175), but I don't understand why wait-online fails in the first place.

My theory is that, based on my current setup on Gulo-Laptop, I have a wireguard config, ethernet, and wifi. My guess is that somehow, the wireguard config interferes with the wait-online detection.

Further investigation is required.

```nix
  systemd.services.NetworkManager-wait-online.enable = false;
```

### Flatpak Icons and Fonts

This is NixOS/nixpkgs#119433, an issue that's two years old.

I haven't encountered many issues with Icons (since I'm not using a custom icon pack), but I definitely missed fonts,
especially multilingual ones. 

To be removed when the above issue is fixed.

```nix
  # https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-1326957279
  # Workaround for 119433
  
  fonts.fontDir.enable = true;

  system.fsPackages = [pkgs.bindfs];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.fonts;
      pathsToLink = ["/share/fonts"];
    };
  in {
    # Create an FHS mount to support flatpak host icons/fonts
    "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
    "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
  };
```

### Blender Steam doesn't run on wayland

The nixpkgs version of Steam doesn't include libdecor, which is needed for Blender in wayland mode. 
It wouldn't launch otherwise.

I didn't bother to make an issue because as far as I know, Blender is the only software in Steam that needs it.

```nix
  # Blender (Steam version) Wayland support
  programs.steam.package = pkgs.steam.override {
    extraLibraries = p:
      with p; [
        libdecor
      ];
  };
```

### Libvirt hook scripts
This is NixOS/nixpkgs#51152, and it's a five year old issue.

But support for hooks has been merged since NixOS/nixpkgs#232250, so it probably will be removed on 23.11

```nix
  # Temporary fix to https://github.com/NixOS/nixpkgs/issues/51152, to be changed when libvirtd.hookModule is implemented
  # TODO migrate to a more paramatric form instead a WHOLLLE script
  systemd.services.libvirtd.preStart = let
    qemuHook = pkgs.writeScript "qemu-hook" ''
      #!${pkgs.stdenv.shell}
```

### Firewall for specific interfaces (openFirewall in modules)

After light research, there's no way to limit `openFirewall` to specific interfaces.

So currently, for these following services, I've manually defined open ports on interfaces:
- Samba

Example
```nix
  networking.firewall.interfaces."virbr1" = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };
```
## picluster