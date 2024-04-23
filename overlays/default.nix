# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { inherit (final) callPackage; pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # nix-community/nurl#220
    nurl = prev.nurl.overrideAttrs (_: oldAttrs: {
      patches = oldAttrs.patches ++ [
        ./nurl-flake.patch
      ];
    });

    # NixOS/nixpkgs#278127
    obs-studio = prev.obs-studio.overrideAttrs (_: oldAttrs: {
      cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DENABLE_LIBFDK=ON" ];
    });

    # NixOS/nixpkgs#119433
    inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.system})
      flatpak;

    # Blender 3.6
    blender-hip_3_6 = prev.blender-hip.overrideAttrs (finalAttrs: oldAttrs: {
      version = "3.6.11";
      src = prev.fetchurl {
        url = "https://download.blender.org/source/${finalAttrs.pname}-${finalAttrs.version}.tar.xz";
        hash = "sha256-mbCrE/flrGIC3VBkn1TrDyZ2pt3gxzhPNPWyXnoJ55I=";
      };

      postInstall = ''
        mv $out/share/blender/${prev.lib.versions.majorMinor finalAttrs.version}/python{,-ext}
        buildPythonPath "$pythonPath"
        wrapProgram $blenderExecutable \
          --prefix PATH : $program_PATH \
          --prefix PYTHONPATH : "$program_PYTHONPATH" \
          --add-flags '--python-use-system-env'
      '';
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  stacked = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
