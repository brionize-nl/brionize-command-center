#!/bin/bash
# BLFS 12.4 — Desktop-File-Utils-0.28. Draait binnen chroot, als root.
# Required: GLib (aanwezig). Aanbevolen bij xfce4-session.
set -euo pipefail
cd /sources
tar -xf desktop-file-utils-0.28.tar.xz
cd desktop-file-utils-0.28

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf desktop-file-utils-0.28
echo "==> Desktop-File-Utils klaar"
