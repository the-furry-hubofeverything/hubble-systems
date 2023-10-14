{config, ...}: {
  /*
  services.kanshi = {
    # enable = true;
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
      test2 = {
        outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
            mode = "1920x1080@60Hz";
            scale = 1.0;
          }
          {
            criteria = "DP-2";
            position = "320,-1440";
            mode = "2560x1440@144Hz";
            #adaptiveSync = true;
          }
          {
            criteria = "HDMI-A-1";
            position = "-2560,-1080";
            mode = "1920x1080@60Hz";
          }
        ];
      };
    };
  };

  xdg.configFile = {
    "hypr/hyprpaper.conf" = {
      text = "
        preload = /run/media/hubble/Data/Commissioned/VRChat_2023-05-20_23-16-04.151_1920x1080(by Woozel).png
        wallpaper = ,/run/media/hubble/Data/Commissioned/VRChat_2023-05-20_23-16-04.151_1920x1080(by Woozel).png
      ";
    };
    "hypr/hyprland.conf" = {
      text = ''
        env=WLR_NO_HARDWARE_CURSORS,1
        env=NIXOS_OZONE_WL,1
        env=WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1

        # toolkit-specific scale
        #env=GDK_SCALE,2
        #env=XCURSOR_SIZE,2

        input {
          numlock_by_default=true

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

          apply_sens_to_raw = 0 # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
        }

        decoration {
            rounding = 10

            blur = true
            blur_size = 3
            blur_passes = 1
            blur_new_optimizations = true
            # Your blur amount is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
            # if you want heavy blur, you need to up the blur_passes.
            # the more passes, the more you can up the blur_size without noticing artifacts.}
        }

        animations {
          enabled = 1
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

        # unscale XWayland
        # xwayland = {
        #   force_zero_scaling = true
        # }


        exec-once=hyprpaper

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

        bind=SUPER,M,exit,
        bind=SUPER,E,exec,dolphin
        bind=SUPER,V,togglefloating,
        bind=SUPER,R,exec,wofi --show drun -o DP-3
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
  };
  */
  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   enableNvidiaPatches = true;
  #   systemdIntegration = true;
  #   settings = {

  #   };
  #   extraConfig =
  # };
}
