{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  qtbase,
  wrapQtAppsHook,
  qtx11extras,
  kcoreaddons,
  ki18n,
  kwindowsystem,
  knotifications,
  kpipewire,
  xdg-desktop-portal-kde,
}:
stdenv.mkDerivation rec {
  pname = "xwaylandvideobridge";
  version = "unstable-2023-10-03";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "58541fa208ec93407c0df1e65a32933c67c83531";
    hash = "sha256-1SRK08wijzoPE4hLBxBexSEVrA8HOGKbPkLrF6qHFpY=";
  };

  buildInputs = [qtbase xdg-desktop-portal-kde];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
    qtx11extras
    kcoreaddons
    ki18n
    kwindowsystem
    knotifications
    kpipewire
  ];

  meta = with lib; {
    description = "Utility to allow streaming Wayland windows to X applications";
    homepage = "https://invent.kde.org/system/xwaylandvideobridge";
    license = with licenses; [gpl2Plus];
    maintainers = with maintainers; [];
  };
}
