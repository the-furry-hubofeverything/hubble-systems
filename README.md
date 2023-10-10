# Hubble's systems

Collection of modules, overlays, and configurations used by my devices. Modified from [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs). 

Check `nix flake info` for outputs.


## File structure

`examples` for template boilerplates. 

`home-manager` for user configs.

`hosts` for machine type/machine specific configs.

`modules` for configs that enable software.

`overlays`, `pkgs` for custom overlays and packages.

## Migration process
Files migrated from machine configs - 
### Gulo-Laptop
- [x] configuration.nix
- [x] hardware-configuration.nix
- [x] omen2020.nix
- [x] workstation.nix
- [x] lanzaboote.nix
- [x] nix-alien.nix
- [x] hyprland.nix
- [x] hubble.nix
- [x] development.nix
- [x] gaming.nix
- [x] gnome.nix
- [x] kdeconnect.nix
- [ ] network-wait-online-mitigation.nix
- [ ] wayland.nix
- [ ] waydroid.nix
- [ ] libvirt.nix
- home-manager configs
    - [ ] home.nix
    - [x] git-credential-oauth.nix

### titan-razer-lcluster
- [x] configuration.nix
- [x] hardware-configuration.nix
- [x] server.nix
## Stacked overlays
### `pkgs.unstable`
nixpkgs unstable
### `pkgs.testing`
the-furry-hubofeverything fork of nixpkgs (master branch)