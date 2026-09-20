#!/bin/bash
# BLFS 12.4 — Pixman-0.46.4. Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf pixman-0.46.4.tar.gz
cd pixman-0.46.4

mkdir build
cd    build
meson setup --prefix=/usr --buildtype=release ..
ninja
# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# ninja test
ninja install

cd /sources
rm -rf pixman-0.46.4
echo "==> Pixman klaar"
