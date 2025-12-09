/*
Code has been modified for Home Manager, Original code license is as follows:

MIT License

Copyright (c) 2023-2025 Fazzi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf getExe;
  cfg = config.services.activate-linux;
in {
  options.services.activate-linux.enable = mkEnableOption "activate-linux";
  config = mkIf cfg.enable {
    systemd.user.services.activate-linux = {
      Unit = {
        Description = "Activate Linux watermark";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        ConditionEnvironment = "WAYLAND_DISPLAY"; # Only start if WAYLAND_DISPLAY env var is set
      };

      Service = {
        Type = "simple";
        Restart = "always";
        ExecStart = "${getExe pkgs.activate-linux}";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
