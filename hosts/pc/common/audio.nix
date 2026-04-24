{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.musnix.nixosModules.musnix
  ];
  
  # Enable pipewire and disable pulseaudio
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  services.pipewire.extraConfig.pipewire."92-clock-rates.conf" = {
    "context.properties" = {
      # Avoids resampling
      "default.clock.allowed-rates" = [44100 48000 88200 96000];
    };
  };

  # Various audio optimizations
    boot = {
      kernel.sysctl = {
        "vm.swappiness" = 10;
      };
      kernelParams = [ "threadirqs" ];
    };

    environment.sessionVariables =
      let
        makePluginPath =
        format:
          "$HOME/.${format}:" +
          (lib.makeSearchPath format [
            "$HOME/.nix-profile/lib"
            "/run/current-system/sw/lib"
            "/etc/profiles/per-user/$USER/lib"
            ]);
      in
      {
        CLAP_PATH = lib.mkDefault (makePluginPath "clap");
        DSSI_PATH = lib.mkDefault (makePluginPath "dssi");
        LADSPA_PATH = lib.mkDefault (makePluginPath "ladspa");
        LV2_PATH = lib.mkDefault (makePluginPath "lv2");
        LXVST_PATH = lib.mkDefault (makePluginPath "lxvst");
        VST3_PATH = lib.mkDefault (makePluginPath "vst3");
        VST_PATH = lib.mkDefault (makePluginPath "vst");
      };
    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
    ];

    services.udev = {
      extraRules = ''
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
    };
  # various daws and stuff
  environment.systemPackages = [
    pkgs.unstable.sfizz-ui
    pkgs.carla
    pkgs.ardour
    pkgs.lsp-plugins
    pkgs.dragonfly-reverb
    pkgs.drumgizmo
    pkgs.drumkv1
    pkgs.geonkick
    pkgs.infamousPlugins
    pkgs.master_me
    pkgs.noise-repellent
    pkgs.odin2
    pkgs.opnplug
    pkgs.padthv1
    pkgs.rubberband
    pkgs.samplv1
    pkgs.setbfree
    pkgs.sorcer
    pkgs.wolf-shaper
    pkgs.zynaddsubfx
    pkgs.yoshimi
    pkgs.zam-plugins
    pkgs.ams
    pkgs.adlplug
    pkgs.artyFX
    pkgs.x42-avldrums
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
