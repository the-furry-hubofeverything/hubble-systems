# Hubble's systems

Collection of modules, overlays, and configurations used by my devices. Modified from [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs). 

Check `nix flake info` for outputs.


## File structure

`examples` for template boilerplates. 

`home-manager` for user configs.

`hosts` for machine type/machine specific configs.
 - You can read the documentation for the machine types [here](hosts/README.md).
 - the "machine types" are arbitrary, just a group of configs that happens to be common among configs.

`overlays`, `pkgs`, `modules` for custom overlays, packages, and modules (that may or may not get upstream to nixpkgs).

## Stacked overlays
### `pkgs.unstable`
nixpkgs unstable