#!/bin/bash
# BLFS 12.4 — Libxcb-1.17.0. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf libxcb-1.17.0.tar.xz
cd libxcb-1.17.0

./configure $XORG_CONFIG \
            --without-doxygen \
            --docdir='${datadir}'/doc/libxcb-1.17.0
LC_ALL=en_US.UTF-8 make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install
chown -Rv root:root $XORG_PREFIX/share/doc/libxcb-1.17.0

cd /sources
rm -rf libxcb-1.17.0
echo "==> Libxcb klaar"
