{ ... }: {
  boot.zfs.extraPools = [
    "tank"
    "main"
  ];

  fileSystems."/run/media/hubble/store0" = {
    device = "/dev/disk/by-partuuid/11a18715-08dd-4b57-9f20-0f5396cba3b2";
    fsType = "ext4";
    options = ["rw" "user" "exec" "errors=remount-ro" "nofail"];
  };

  fileSystems."/run/media/hubble/store1" = {
    device = "/dev/disk/by-partuuid/cef73c67-c122-4943-905a-10b3bf9e62bf";
    fsType = "ext4";
    options = ["rw" "user" "exec" "errors=remount-ro" "nofail"];
  };

  fileSystems."/run/media/hubble/mass" = { 
    device = "/run/media/hubble/store*";
    fsType = "mergerfs";
    options = ["defaults" "minfreespace=250G" "cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
  };

  # TODO Samba? NFS?
  
}