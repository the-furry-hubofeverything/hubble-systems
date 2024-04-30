{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opencomposite
  ];

  service.monado = {
    enable = true;
    defaultRuntime = true;
  };
}
