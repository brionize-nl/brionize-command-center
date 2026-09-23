#!/bin/bash
# BLFS 12.4 — Garcon-4.20.0. Draait binnen chroot, als root.
# Required: libxfce4ui, GTK3 — allemaal al aanwezig.
set -euo pipefail
cd /sources
tar -xf garcon-4.20.0.tar.bz2
cd garcon-4.20.0

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd /sources
rm -rf garcon-4.20.0
echo "==> Garcon klaar"
