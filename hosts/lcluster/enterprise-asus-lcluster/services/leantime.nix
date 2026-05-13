{config, outputs, pkgs, ...}: {
  imports = [
    outputs.nixosModules.leantime
  ];

  services.leantime = {
    enable = true;
    pool = {
      listenOwner = "nginx";
      listenGroup = "nginx";
    };
    dataDir = "/persist/leantime";
  };
  services.nginx.virtualHosts."leantime.gulo.dev" = {
    useACMEHost = "gulo.dev";
    forceSSL = true;
    root = "${config.services.leantime.package}/share/php/leantime/public";

    locations = {
      "/" = {
        tryFiles = "$uri $uri/ /index.php?$query_string";
      };

      "~ \.php$" = {
        extraConfig = ''
          fastcgi_index index.php;
          fastcgi_pass unix:${config.services.phpfpm.pools."leantime".socket};
          include ${pkgs.nginx}/conf/fastcgi.conf;
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        '';
      };
    };

    extraConfig = ''
      index index.php index.html index.htm;
      location ~ /\.ht {
          deny all;
      }
    '';
  };
}
