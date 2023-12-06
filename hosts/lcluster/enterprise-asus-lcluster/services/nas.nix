{ ... }: {
  boot.zfs.extraPools = [
    "tank"
    "main"
  ];

  # TODO Samba? NFS?
  
}