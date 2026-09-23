#!/bin/bash
# BLFS 12.4 — Xfconf-4.20.0. Draait binnen chroot, als root.
# Required: libxfce4util (vorige stap).
set -euo pipefail
cd /sources
tar -xf xfconf-4.20.0.tar.bz2
cd xfconf-4.20.0

./configure --prefix=/usr
make
make install

cd /sources
rm -rf xfconf-4.20.0
echo "==> Xfconf klaar"
