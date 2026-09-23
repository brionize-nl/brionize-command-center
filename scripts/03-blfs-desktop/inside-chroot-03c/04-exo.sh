#!/bin/bash
# BLFS 12.4 — Exo-4.20.0. Draait binnen chroot, als root.
# Required: GTK3, libxfce4ui, libxfce4util — allemaal al aanwezig.
set -euo pipefail
cd /sources
tar -xf exo-4.20.0.tar.bz2
cd exo-4.20.0

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd /sources
rm -rf exo-4.20.0
echo "==> Exo klaar"
