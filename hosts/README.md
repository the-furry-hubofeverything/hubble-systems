# Hosts

## Instructions 

Each folder should only contain machine specific `configuration.nix` and `hardware-configuration.nix`. Everything else should either be imported or exist as an module. **No NixOS module is to be imported in machine specific `configuration.nix`.** 

### Add a machine

Let's add `Gulo-Laptop`!

1. Create folder `gulo-laptop` (Doesn't have to be full hostname) in `hosts/pc` (create new type if doesn't exist)
2. Create entry in `hosts/default.nix`
```
[...]
  # Entry MUST be full hostname for `nixos-rebuild`
  Gulo-Laptop = {
    # Arch and OS
    platform = "x86_64-linux";
    # Modules specific to machine
    modules =
      # adding shared modules for the `pc` machine type
      pc.modules 
      ++ [
        # machine specific configuration.nix
        ./pc/gulo-laptop/configuration.nix

        # Other modules
        nixos-hardware.omen-15-en0010ca

        inputs.lanzaboote.nixosModules.lanzaboote
        outputs.nixosModules.lanzaboote
      ];
  };
[...]
```
3. Don't forget to import common configs in `configuration.nix` for `Gulo-Laptop`
```
  imports = [
    ../common.nix
  ] 
```

### Modules
Modules that are shared with each machine type is declared with `default.nix` in those folders. Specific modules are declared in `systems/default.nix` for tidiness.

### Configrations
#### Setting timezones
Timezones are all in the common.nix folders for each machine type, under `time.timeZone`

## Machine types
### Lighthouse
Coming soon. Plan to use various free/droplet tiers (Linode, Oracle, etc).

### Pi cluster
Pis for lightweight services.

| Nickname | Model | Hostname | Notes |
|-|-|-|-|
| pinky | Raspberry Pi 3B v1.2 | pinky-pi3-picluster |  |
| brain | Raspberry Pi 4B | brain-pi4-picluster| |

### Laptop cluster
Old laptops for builds and services. These should have ephemeral roots.

| Nickname | Model | Hostname | CPU | GPU | Notes |
|-|-|-|-|-|-|
| titan | Razer Blade 15 RZ09-01953 | titan-razer-lcluster | i7-7700HQ | GTX 1060 |Battery available, but no ethernet or screen |
| enterprise | ASUS FX53VD | enterprise-asus-lcluster | i7-7700HQ | GTX 1050 | DVD drive available, no battery |

### Personal Computers
| Nickname | Model | Hostname | CPU | GPU | Notes |
|-|-|-|-|-|-|
| Gulo-Laptop | HP OMEN 15-en0010ca | Gulo-Laptop | Ryzen 7 4800H | GTX 1660 Ti | Daily Driver |

## Services wishlist

- DNS
- With rotating keys
  - SSH
  - Wireguard
- Distributed storage
- Blender rendering (local and remote combied)
- Certificate updates
- Vaultwarden
- Kopia
- Grocy
- Samba
- nextcloud (?)
- Video encoding
- Speech transcription/recognition