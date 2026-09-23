#!/bin/bash
# BLFS 12.4 — hicolor-icon-theme-0.18. Draait binnen chroot, als root.
# Runtime-dependency van thunar (fallback icon-thema). Geen dependencies.
set -euo pipefail
cd /sources
tar -xf hicolor-icon-theme-0.18.tar.xz
cd hicolor-icon-theme-0.18

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf hicolor-icon-theme-0.18
echo "==> hicolor-icon-theme klaar"
