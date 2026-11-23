{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  glib,
  gtk3,
  libdbusmenu,
  libdbusmenu-gtk3,
  libX11,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "appmenu-gtk-module-wayland";
  version = "0-unstable-2026-11-03";

  src = fetchFromGitHub {
    owner = "guiodic";
    repo = "appmenu-gtk-module-wayland";
    rev = "3fb3b70c73018ddeb65828d58301712d0fb86a8e";
    hash = "sha256-1x4wEYWaCvzJSYI8P7MglS22yPSMalGryqvQVfaFvS4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    glib.dev # neste nixpkgs o glib-compile-schemas está no output dev
  ];

  buildInputs = [
    glib
    gtk3
    libdbusmenu
    libdbusmenu-gtk3
    libX11
    wayland
  ];

  cmakeFlags = [
    # O default do upstream é /etc/profile.d, que fica fora do store.
    (lib.cmakeFeature "PROFILE_INSTALL_DIR" "${placeholder "out"}/etc/profile.d")
  ];

  postInstall = ''
    glib-compile-schemas --strict $out/share/glib-2.0/schemas
  '';

  meta = {
    description = "GTK3 module that exports application menus on Plasma Wayland";
    homepage = "https://github.com/guiodic/appmenu-gtk-module-wayland";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
