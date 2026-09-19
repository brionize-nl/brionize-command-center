#!/bin/bash
# LFS 12.4 hoofdstuk 8.26 — Libcap-2.76. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf libcap-2.76.tar.xz
cd libcap-2.76

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=/usr lib=lib

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make test

make prefix=/usr lib=lib install

cd /sources
rm -rf libcap-2.76
echo "==> Libcap klaar"
