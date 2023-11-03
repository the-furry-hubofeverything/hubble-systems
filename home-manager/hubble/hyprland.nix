{config, pkgs, inputs, ...}: {

  home.packages = [
    pkgs.wofi
    pkgs.hyprpaper
    pkgs.mako
  ];


  gtk.enable = true;

  services.kanshi = {
    # use wdisplays to set the positions, then look at 'hyprctl monitors' for positions
    enable = true;
    systemdTarget = "graphical-session.target";
    profiles = {
      laptop-internal = {
        outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
            mode = "1920x1080@60Hz";
            scale = 1.0;
          }
        ];
      };
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            position = "2320,1548";
            mode = "1920x1080@60Hz";
            scale = 1.0;
          }
          {
            criteria = "DP-2";
            position = "2019,108";
            mode = "2560x1440@144Hz";
            # adaptive_sync = true;
          }
          {
            criteria = "HDMI-A-1";
            position = "99,468";
            mode = "1920x1080@60Hz";
          }
        ];
      };
    };
  };

  xdg.configFile = {
    "hypr/hyprpaper.conf" = {
      # Wallpaper has monitor wildcard - leave the comma alone!
      text = ''
        preload = /run/media/hubble/Data/backgrounds/CuteMallv2-AgX-16-9.png
        wallpaper = ,/run/media/hubble/Data/backgrounds/CuteMallv2-AgX-16-9.png
      '';
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    systemdIntegration = true;
    xwayland.enable = true;
    extraConfig = ''
      input {
        numlock_by_default = true

        follow_mouse = 1
        touchpad {
          natural_scroll = true
        }
      }

      general {
        sensitivity = 1.0 # for mouse cursor

        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = 0x66ee1111
        col.inactive_border = 0x66333333

        apply_sens_to_raw = false # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
      }

      decoration {
        rounding = 10
        blur {
          enabled = true
          size = 3
          passes = 1
          new_optimizations = true
          # Your blur amount is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
          # if you want heavy blur, you need to up the blur_passes.
          # the more passes, the more you can up the blur_size without noticing artifacts.}
        }
      }

      animations {
        enabled = true
      }

      gestures {
        workspace_swipe = true
      }

      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }

      dwindle {
        pseudotile = true # enable pseudotiling on dwindle
      }

      env=WLR_NO_HARDWARE_CURSORS,1
      env=WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1
      # env = LIBVA_DRIVER_NAME,nvidia
      # env = XDG_SESSION_TYPE,wayland
      # env = GBM_BACKEND,nvidia-drm
      # env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      
      env = WLR_NO_HARDWARE_CURSORS,1
      exec-once=hyprpaper
      exec-once=mako

      bezier=expoOut,0.19,1,0.22,1
      bezier=expoIn,0.95,0.05,0.795,0.035
      animation=windows,1,7,expoOut
      animation=border,0,10,expoOut
      animation=fadeIn,1,5,expoOut
      animation=workspaces,1,6,expoOut

      bind=SUPER,Q,exec,kitty
      bind=ALT,f4,killactive

      # Example volume button that allows press and hold, volume limited to 150%
      binde=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      binde=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      
      # binde=, XF86Calculator, exec, calculator here

      bind=SUPER,M,exit,
      bind=SUPER,E,exec,nautilus
      bind=SUPER,V,togglefloating,
      bind=SUPER,R,exec,wofi --show drun
      bind=SUPER,P,pseudo,
      bind=SUPER,F,fullscreen
      bind=SUPER,W,togglegroup


      bindm=SUPER,mouse:272,movewindow
      bindm=SUPER+SHIFT,mouse:272,resizewindow
      bind=SUPER,mouse_down,workspace,e-1
      bind=SUPER,mouse_up,workspace,e+1

      bind=SUPER,left,movewindow,l
      bind=SUPER,right,movewindow,r
      bind=SUPER,up,movewindow,u
      bind=SUPER,down,movewindow,d

      # workspaces
      # binds SUPER and Alt + {1..10} to [move to] workspace {1..10}
      ${builtins.concatStringsSep "\n" (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in ''
            bind = SUPER, ${ws}, workspace, ${toString (x + 1)}
            bind = ALT, ${ws}, movetoworkspace, ${toString (x + 1)}
          ''
        )
      10)}
    '';
  };
}
