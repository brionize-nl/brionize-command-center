#!/bin/bash
# BLFS 12.4 — Xcb-util-0.4.1. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf xcb-util-0.4.1.tar.xz
cd xcb-util-0.4.1

./configure $XORG_CONFIG
make
make install

cd /sources
rm -rf xcb-util-0.4.1
echo "==> Xcb-util klaar"
