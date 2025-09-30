# Hosts

Each folder should only contain machine specific `configuration.nix` and `hardware-configuration.nix`. Everything else should either be imported or exist as an module. **No NixOS module is to be imported in machine specific `configuration.nix`.** 

> [!NOTE]
> Workarounds are listed [here](workarounds.md).<br>
> When debugging, its best to start here.

## Add a machine type

1. Create folder in `./hosts` (this directory), named whatever you want the machine type to be.
2. Create a file named `common.nix`, and use that as configuration that applies to all machines in the folder.
  - you can also create a "common" folder for decluttering the main `common.nix`.
3. Add entry to `sharedModules` in `./hosts/default.nix`:
```
  sharedModules = {
    lCluster = [
      # the machine type's common config
      ./lcluster/common.nix

      # any modules you want to apply across all machines in type
      nixos-hardware.common-pc
      nixos-hardware.common-pc-hdd
      nixos-hardware.common-pc-ssd
      nixos-hardware.common-pc-laptop
      nixos-hardware.common-pc-laptop-hdd

      inputs.sops-nix.nixosModules.sops
    ];
  };
```
4. follow the rest of the instructions in (see [Add a machine](#add-a-machine))

## Add a machine

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
      sharedModules.pc 
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

## Configurations
### Setting timezones
Timezones are all in the common.nix folders for each machine type, under `time.timeZone`

## Machine types
### Lighthouse
Coming soon. Plan to use various free/droplet tiers (Linode, Oracle, etc).

### [Pi cluster](picluster/README.md)
Pis for lightweight services.

| Nickname | Model | Hostname | Notes |
|-|-|-|-|
| pinky | Raspberry Pi 3B v1.2 | pinky-pi3-picluster |  |
| brain | Raspberry Pi 4B | brain-pi4-picluster| |

### [Laptop cluster](lcluster/README.md)
Old laptops for builds and services. These should have ephemeral roots.

| Nickname | Model | Hostname | CPU | GPU | Notes |
|-|-|-|-|-|-|
| titan | Razer Blade 15 RZ09-02886E92 | titan-razer-lcluster | i7-8750H | RTX 2060 | no ethernet or battery |
| enterprise | ASUS FX53VD | enterprise-asus-lcluster | i7-7700HQ | GTX 1050 | DVD drive available, no battery |

### [Personal Computers](pc/README.md)
| Nickname | Model | Hostname | CPU | GPU | Notes |
|-|-|-|-|-|-|
| Gulo-Laptop | HP OMEN 15-en0010ca | Gulo-Laptop | Ryzen 7 4800H | GTX 1660 Ti | Daily Driver |

### [Cloud instances](remote/README.md)
| Nickname | Model | Hostname | CPU | GPU | Notes |
|-|-|-|-|-|-|
| alex | Oracle Free Tier | alex-oracle-remote | 4 vCPU | - | 24 GB RAM |
| alan | Google Free Tier | alan-google-remote | 0.25 vCPU | - | 1 GB RAM, can't use nixos-anywhere |
