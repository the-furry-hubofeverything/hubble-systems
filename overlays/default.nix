# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev:
    import ../pkgs {
      inherit (final) callPackage;
      pkgs = final;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # nix-community/nurl#220
    # nurl = prev.nurl.overrideAttrs (_: oldAttrs: {
    #   patches =
    #     oldAttrs.patches
    #     ++ [
    #       ./nurl-flake.patch
    #     ];
    # });

    supergfxctl = prev.supergfxctl.overrideAttrs (_: oldAttrs: rec {
      version = "5.2.7";

      src = prev.fetchFromGitLab {
        owner = "the-furry-hubofeverything";
        repo = "supergfxctl";
        rev = "0db0bc7c4a21d20dbd8c3dbf1524437f2dc252e5";
        hash = "sha256-9W2NA2VtoJz/pW7sBlgyQIUTZ/yM0oYwVN2yqXC5jI0=";
      };

      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-LAJC56FhIE5gmKTFLYCAp9FDg8CeSHo+z+gbdTZYNf8=";
      };
    });

    # # Blender 3.6
    # blender-hip_3_6 = prev.blender-hip.overrideAttrs (finalAttrs: oldAttrs: {
    #   version = "3.6.11";
    #   src = prev.fetchurl {
    #     url = "https://download.blender.org/source/${finalAttrs.pname}-${finalAttrs.version}.tar.xz";
    #     hash = "sha256-mbCrE/flrGIC3VBkn1TrDyZ2pt3gxzhPNPWyXnoJ55I=";
    #   };

    #   postInstall = ''
    #     mv $out/share/blender/${prev.lib.versions.majorMinor finalAttrs.version}/python{,-ext}
    #     buildPythonPath "$pythonPath"
    #     wrapProgram $blenderExecutable \
    #       --prefix PATH : $program_PATH \
    #       --prefix PYTHONPATH : "$program_PYTHONPATH" \
    #       --add-flags '--python-use-system-env'
    #   '';
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  stacked = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;

      # TODO needed for VINTAGE STORY
      config.permittedInsecurePackages = [
        "dotnet-runtime-7.0.20"
      ];
    };
  };
}
