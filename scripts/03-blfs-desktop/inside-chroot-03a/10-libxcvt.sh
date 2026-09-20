#!/bin/bash
# BLFS 12.4 — Libxcvt-0.1.3. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf libxcvt-0.1.3.tar.xz
cd libxcvt-0.1.3

mkdir build
cd    build
meson setup --prefix=$XORG_PREFIX --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf libxcvt-0.1.3
echo "==> Libxcvt klaar"
