#!/bin/bash
# BLFS 12.4 — Libdrm-2.4.125. Draait binnen chroot, als root.
# Toegevoegd na een echte build-fout: xorg-server (13-xorg-server.sh)
# faalt tijdens ninja (niet configure) op "xf86drm.h: No such file or
# directory" in hw/xfree86/os-support/linux/lnx_platform.c — DRM/KMS-
# modesetting-ioctls worden gebruikt onafhankelijk van glamor/GLX.
# Libdrm zelf heeft GEEN Mesa nodig (BLFS: alleen "Recommended: Xorg
# Libraries", al aanwezig) — losstaand, licht pakket.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf libdrm-2.4.125.tar.xz
cd libdrm-2.4.125

mkdir build
cd build

meson setup --prefix=$XORG_PREFIX \
  --buildtype=release   \
  -D udev=true          \
  -D valgrind=disabled  \
  ..
ninja
ninja install

cd /sources
rm -rf libdrm-2.4.125
echo "==> Libdrm klaar"
