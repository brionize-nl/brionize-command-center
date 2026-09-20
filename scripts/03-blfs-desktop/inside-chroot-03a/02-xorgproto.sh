#!/bin/bash
# BLFS 12.4 — Xorgproto-2024.1. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf xorgproto-2024.1.tar.xz
cd xorgproto-2024.1

mkdir build
cd    build

meson setup --prefix=$XORG_PREFIX ..
ninja
ninja install
mv -v $XORG_PREFIX/share/doc/xorgproto{,-2024.1}

cd /sources
rm -rf xorgproto-2024.1
echo "==> Xorgproto klaar"
