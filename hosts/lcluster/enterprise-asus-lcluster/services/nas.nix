{ ... }: 
let 
  commonPerms = {
    "read only" = "no";
    "guest ok" = "no";
    "valid users" = "hubble";
    browsable = "yes";
  };
in {
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

  fileSystems."/mass" = { 
    device = "/run/media/hubble/store*";
    fsType = "mergerfs";
    options = ["defaults" "minfreespace=250G" "cache.files=partial" "dropcacheonclose=true" "category.create=mfs"];
  };

  # TODO NFS Mesh net wide share
  services.samba = {
    enable = true;

    # Global config
    extraConfig = 
      ''
        interfaces = wt0, 192.168.1.0/24, lo
        bind interfaces only = yes

        create mask = 0664
        force create mode = 0664
        directory mask = 0775
        force directory mode = 0775
        follow symlinks = yes

        # Performance
        read raw = yes
        write raw = yes
        use sendfile = yes
        socket options = IPTOS_LOWDELAY TCP_NODELAY IPTOS_THROUGHPUT
        min protocol = smb2
        deadtime = 30

        # Disable printer sharing
        load printers = no
        printing = bsd
        printcap name = /dev/null
        disable spoolss = yes
        show add printer wizard = no

        # Hardening
        server min protocol = SMB3_11
        client ipc min protocol = SMB3_11
        client signing = mandatory
        server signing = mandatory
        client ipc signing = mandatory
        client NTLMv2 auth = yes
        smb encrypt = required
        restrict anonymous = 2
        raw NTLMv2 auth = no
      '';

    shares = {
      tank = commonPerms // {
        path = "/tank";
        comment = "Storage under RAID 1";
      };
      main = commonPerms // {
        path = "/main";
        comment = "Storage under RAID 10";
      };
      mass = commonPerms // {
        path = "/mass";
        comment = "Storage without RAID";
      };
    };
    openFirewall = true;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/samba"
    ];
  };
}