#!/bin/bash
# BLFS 12.4 — libwnck-43.2. Draait binnen chroot, als root.
# Required: GTK3 (uit 03b). Aanbevolen: GLib met introspectie
# (aanwezig), startup-notification (al gebouwd, stap 00d).
set -euo pipefail
cd /sources
tar -xf libwnck-43.2.tar.xz
cd libwnck-43.2

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf libwnck-43.2
echo "==> libwnck klaar"
