{ ... }: {
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  
  services.zfs.autoScrub = {
    enable = true;
    interval = "Mon,Fri 03:00";
  };
}