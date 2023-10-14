# Hubble's systems

Collection of modules, overlays, and configurations used by my devices. Modified from [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs). 

Check `nix flake info` for outputs.


## File structure

`examples` for template boilerplates. 

`home-manager` for user configs.

`hosts` for machine type/machine specific configs.

`modules` for configs that enable software.

`overlays`, `pkgs` for custom overlays and packages.

## Stacked overlays
### `pkgs.unstable`
nixpkgs unstable
### `pkgs.testing`
the-furry-hubofeverything fork of nixpkgs (master branch)