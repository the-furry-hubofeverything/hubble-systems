_: {
  boot.supportedFilesystems = ["btrfs"];
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };
}
