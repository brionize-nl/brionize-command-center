#!/bin/bash
# BLFS 12.4 — Xcb-proto-1.17.0. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf xcb-proto-1.17.0.tar.xz
cd xcb-proto-1.17.0

PYTHON=python3 ./configure $XORG_CONFIG
# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check
make install

cd /sources
rm -rf xcb-proto-1.17.0
echo "==> Xcb-proto klaar"
