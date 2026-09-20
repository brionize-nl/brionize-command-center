#!/bin/bash
# BLFS 12.4 — LibXau-1.0.12. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf libXau-1.0.12.tar.xz
cd libXau-1.0.12

./configure $XORG_CONFIG
make
make install

cd /sources
rm -rf libXau-1.0.12
echo "==> LibXau klaar"
