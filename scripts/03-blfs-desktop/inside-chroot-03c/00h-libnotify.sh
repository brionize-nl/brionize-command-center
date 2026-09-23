#!/bin/bash
# BLFS 12.4 — libnotify-0.8.6. Draait binnen chroot, als root.
# Required: GTK3 (aanwezig uit 03b). Aanbevolen bij thunar/
# thunar-volman/xfce4-settings/xfdesktop. Runtime heeft dit zelf een
# notificatiedaemon nodig (bv. xfce4-notifyd, uit "Xfce Applications" —
# een latere, aparte apps-sub-fase) — niet nodig om libnotify zelf te
# bouwen. '-D man=false' (geen rst2man/docutils-afhankelijkheid nodig
# voor man-pages, zelfde reden als eerder bij GLib/gdk-pixbuf/GTK3).
set -euo pipefail
cd /sources
tar -xf libnotify-0.8.6.tar.xz
cd libnotify-0.8.6

mkdir build
cd build

meson setup --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false    \
    -D man=false        \
    ..
ninja
ninja install

cd /sources
rm -rf libnotify-0.8.6
echo "==> libnotify klaar"
