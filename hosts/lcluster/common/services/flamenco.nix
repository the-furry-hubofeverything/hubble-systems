{ config, options, ... }: {
  services.flamenco = {
    enable = true;
    role = ["worker"];
  };
}