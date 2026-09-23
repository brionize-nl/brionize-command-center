#!/bin/bash
# BLFS 12.4 — xfce4-appfinder-4.20.0. Draait binnen chroot, als root.
# Required: Garcon (aanwezig).
set -euo pipefail
cd /sources
tar -xf xfce4-appfinder-4.20.0.tar.bz2
cd xfce4-appfinder-4.20.0

./configure --prefix=/usr
make
make install

cd /sources
rm -rf xfce4-appfinder-4.20.0
echo "==> xfce4-appfinder klaar"
