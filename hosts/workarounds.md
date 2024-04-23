# Workarounds
All the jank in the hosts configuration.

A solution is considered a workaround when the problem or solution evolves from something unintentional, like a bug or a unintentional feature that could be removed at any time. This means that these workarounds may stop working at any time.

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

### Flamenco GPU select

Since Blender is notoriously difficult to work with in terms of GPU selection in command line arguments, a script is needed to utilize the GPU. 

Workaround 1 - I used a script from [Stack Exchange](https://blender.stackexchange.com/a/256665), but I think I want to customize it later, just so I can be a bit more flexible with the choices. 

Workaround 2 - I couldn't figure out how to add the script to the nix store without making it a package, so I used `systemd.tmpfiles`. There's got to be better way, but I don't know yet. 

```nix
  systemd.tmpfiles.rules = [
    # WORKAROUND - I can't define the file under flamenco variables, or else the file
    #              would not be included in the nix store of the workers. 
    "L+ /run/flamenco/gpu-autoselect.py 0755 render render - ${gpu-autoselect}"
  ];
```

## pc

### Flatpak Icons and Fonts

This is NixOS/nixpkgs#119433.

I haven't encountered many issues with Icons (since I'm not using a custom icon pack), but I definitely missed fonts,
especially multilingual ones. 

Current workaround - using nixos-unstable flatpak.

TODO: remove for 24.05

```nix
    # NixOS/nixpkgs#119433
    inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.system})
      flatpak;
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
    nurl = prev.nurl.overrideAttrs (_: oldAttrs: {
      patches = oldAttrs.patches ++ [
        ./nurl-flake.patch
      ];
    });
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

Gnome shenanigans. 

The problem arises when I plug in my DP monitor. Then, black screen until I remove the cable. 

Gnome 45 has a new experimental separate thread for KMS (kernel mode setting). Unfortunately GPU drivers hasn't been nice to it, since their operations take longer than the scheduler expects, and it contributes to GNOME's rlimit, which then the kernel kills because it was exceeded.

But the source of the problem eludes me, and it seems like there's a whole host of problems that went along this change (https://gitlab.gnome.org/GNOME/mutter/-/issues/3151).

As of March 29, 2024, I'm too burnt out to deal with this. I really don't want to work with Gnome folks.

May switch to KDE.

```nix
  # KMS thread workaround
  environment.variables = {
    MUTTER_DEBUG_KMS_THREAD_TYPE = "user";
  };
```

### OBS missing libfdk AAC encoder

Fixed in NixOS/nixpkgs#278127, but not until NixOS 24.05.

```nix
  obs-studio = prev.obs-studio.overrideAttrs (_: oldAttrs: {
    cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DENABLE_LIBFDK=ON" ];
  });
```

### Blender 3.6

Am working on adding it in nixpkgs, but for now I'm doing a bit of a hack
```nix
  # Blender 3.6
  blender-hip_3_6 = prev.blender-hip.overrideAttrs (finalAttrs: oldAttrs: {
    version = "3.6.11";
    src = prev.fetchurl {
      url = "https://download.blender.org/source/${finalAttrs.pname}-${finalAttrs.version}.tar.xz";
      hash = "sha256-mbCrE/flrGIC3VBkn1TrDyZ2pt3gxzhPNPWyXnoJ55I=";
    };
  });
```

## picluster