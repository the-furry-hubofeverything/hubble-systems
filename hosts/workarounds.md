# Workarounds
All the jank in the hosts configuration.

A solution is considered a workaround when the problem or solution evolves from something unintentional, like a bug or a unintentional feature that could be removed at any time. This means that these workarounds may stop working at any time.

As of Oct 24, 2023, not all workarounds may be documented. This line will be removed once I'm confident all workarounds are documented.

> [!IMPORTANT]
> These workarounds may not work after source flake updates. <br>
> When debugging, check workarounds first to see if the subjects debugged are affected.

> [!NOTE]
> If you are maintaining the flake that is relevant to the workaround, I would be happy to be included in the conversation.

## lcluster

### Impermanence certificate owner handling

Since the user is defined in nixpkgs, we'll use the same logic as they do.
```nix
  sops.secrets.porkbun-api-key.owner = if config.security.acme.useRoot then "root" else "acme";
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
{ pkgs, lib, config, ... }: {
  # https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-1326957279
  # Workaround for 119433

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    aggregatedIcons = pkgs.buildEnv {
      name = "system-icons";
      paths = if (config.services.xserver.desktopManager.gnome.enable) then lib.singleton pkgs.gnome.gnome-themes-extra else lib.singleton pkgs.libsForQt5.breeze-qt5;
      pathsToLink = [ "/share/icons" ];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.packages;
      pathsToLink = [ "/share/fonts" ];
    };
  in {
    "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
    "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
  };
  
  fonts.fontDir.enable = true;
}
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
  # TODO migrate to a more parametric form instead a WHOLLLE script
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

### nurl flake address problem

See [PR](https://github.com/nix-community/nurl/pull/220)

`nurl`, at this point, generates command that is inoperable on this system, which breaks my script written for nixpkgs ONLY for systems from this config. This fixes it.

```nix
  environment.systemPackages = with pkgs; [
    (nurl.overrideAttrs (_: prev: {
      patches = prev.patches ++ [
        ./nurl-flake.patch
      ];
    }))
```

### HIP workaround

> [!NOTE] 
> This may need to be updated for 23.11

This is required for HIP to work with (at the very least) Blender, even with hipSupport enabled. This is documented on the user-maintained nixos wiki https://nixos.wiki/wiki/AMD_GPU

> Most software has the HIP libraries hard-coded. You can work around it on NixOS by using: 
```nix
  # HIP workaround
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
```

### Gnome 45 KMS thread problems with video driver

TODO: document

```nix
  # KMS thread workaround
  environment.variables = {
    MUTTER_DEBUG_KMS_THREAD_TYPE = "user";
  };
```

## picluster