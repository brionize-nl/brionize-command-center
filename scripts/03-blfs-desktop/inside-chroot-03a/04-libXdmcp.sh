#!/bin/bash
# BLFS 12.4 — LibXdmcp-1.1.5. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf libXdmcp-1.1.5.tar.xz
cd libXdmcp-1.1.5

./configure $XORG_CONFIG --docdir=/usr/share/doc/libXdmcp-1.1.5
make
make install

cd /sources
rm -rf libXdmcp-1.1.5
echo "==> LibXdmcp klaar"
