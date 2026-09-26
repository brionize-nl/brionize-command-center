#!/bin/bash
# Compileert en installeert command-center-kiosk (eigen C-broncode,
# geen BLFS-pakket) + command-center-webapp-add (bash). Draait binnen
# chroot, als root. Bronbestanden staan gebind-mount op
# /opt/lfs-kiosk-shell-src (zie run-all.sh).
#
# pkg-config-modulenaam voor WebKitGTK bevestigd tegen de echte
# WebKitGTK-broncode (Source/WebKit/gtk/webkitgtk.pc.in +
# Source/cmake/OptionsGTK.cmake's WEBKITGTK_API_INFIX="2"/
# WEBKITGTK_API_VERSION="4.1" voor onze GTK3+libsoup3-combinatie):
# "webkit2gtk-4.1" — geen aparte find_package/cmake-omgeving nodig,
# gewoon rechtstreeks gcc + pkg-config, want dit is een eigen, klein
# los programma, geen BLFS-bouwsysteem.
set -euo pipefail

SRC_DIR="/opt/lfs-kiosk-shell-src"
BUILD_DIR="/sources/command-center-kiosk-build"

mkdir -pv "$BUILD_DIR"
cd "$BUILD_DIR"

gcc -O2 -Wall \
    $(pkg-config --cflags webkit2gtk-4.1 gtk+-3.0) \
    -o command-center-kiosk \
    "$SRC_DIR/command-center-kiosk.c" \
    $(pkg-config --libs webkit2gtk-4.1 gtk+-3.0)

install -v -m755 command-center-kiosk /usr/local/bin/command-center-kiosk
install -v -m755 "$SRC_DIR/command-center-webapp-add" /usr/local/bin/command-center-webapp-add

# Leeg sjabloon voor nieuwe gebruikers (zelfde /etc/skel-patroon als
# fase 3d's devilspie2-tegelregels) — command-center-webapp-add maakt
# de map+bestand zelf ook aan als die nog ontbreken, dit is puur zodat
# een nieuwe gebruiker een leeg, geldig bestand heeft i.p.v. helemaal
# niets.
mkdir -pv /etc/skel/.config/command-center
: > /etc/skel/.config/command-center/webapps.ini

cd /sources
rm -rf "$BUILD_DIR"
echo "==> command-center-kiosk + command-center-webapp-add geïnstalleerd"
