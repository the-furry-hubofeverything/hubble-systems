# lcluster

## Disko config for lcluster

1. Copy disko-config.nix to `/tmp` on system running nixos installer
2. REMEMBER TO CHANGE SETTINGS OUTLINED WITH COMMENTS
3. Run `sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko /tmp/disko-config.nix`
4. Mount root of disk in a different directory, and create a snapshot.
  - For example, with btrfs root mounted on `/mntroot`,  run `sudo btrfs subvolume snapshot -r /mntroot/root /mntroot/root-blank`
5. Run `sudo nixos-generate-config --root /mnt`
6. Profit!!! (hopefully)

## Services wishlist

- ~~DNS~~
- With rotating keys
  - SSH
  - Wireguard
- Distributed storage
- ~~Blender rendering (local and remote combined)~~
- ~~Certificate updates~~
- ~~Vaultwarden~~
- Kopia
- ~~Grocy~~
- ~~Samba~~
- nextcloud (?)
- Video encoding
- Speech transcription/recognition