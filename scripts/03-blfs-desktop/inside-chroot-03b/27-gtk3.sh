#!/bin/bash
# BLFS 12.4 — GTK3-3.24.50. Draait binnen chroot, als root.
# Laatste stap van fase 3b. Required: at-spi2-core, gdk-pixbuf,
# libepoxy, Pango — allemaal al aanwezig. Effectief ook vereist:
# GLib-met-introspectie (aanwezig sinds stap 07-09). Wayland-backend
# wordt door meson automatisch overgeslagen (wayland/wayland-protocols
# niet aanwezig, bewust X11-only-doel) — geen losse vlag nodig.
set -euo pipefail
cd /sources
tar -xf gtk-3.24.50.tar.xz
cd gtk-3.24.50

mkdir build
cd build

meson setup ..            \
    --prefix=/usr       \
    --buildtype=release \
    -D man=true         \
    -D broadway_backend=true
ninja
ninja install

cd /sources
rm -rf gtk-3.24.50
echo "==> GTK3 klaar — fase 3b (GTK3-supporting-stack) compleet"
