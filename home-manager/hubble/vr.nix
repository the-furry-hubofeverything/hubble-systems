{
  pkgs,
  inputs,
  hostConfig,
  config,
  ...
}: let
  monado = hostConfig.config.services.monado.package;
in {
  nixpkgs.overlays = [
    inputs.nixpkgs-xr.overlays.default
  ];

  # For Monado:
  xdg.configFile."openxr/1/active_runtime.json".source = "${monado}/share/openxr/1/openxr_monado.json";

  xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    {
      "config" :
      [
        "${config.xdg.dataHome}/Steam/config"
      ],
      "external_drivers" : [
        "${monado}/share/steamvr-monado"
      ],
      "jsonid" : "vrpathreg",
      "log" :
      [
        "${config.xdg.dataHome}/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.opencomposite}/lib/opencomposite"
      ],
      "version" : 1
    }
  '';
}
