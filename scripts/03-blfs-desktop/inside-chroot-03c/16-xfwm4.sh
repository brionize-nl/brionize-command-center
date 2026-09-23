#!/bin/bash
# BLFS 12.4 — Xfwm4-4.20.0. Draait binnen chroot, als root.
# Required: libwnck, libxfce4ui — allemaal al aanwezig. Aanbevolen:
# startup-notification (00d).
set -euo pipefail
cd /sources
tar -xf xfwm4-4.20.0.tar.bz2
cd xfwm4-4.20.0

./configure --prefix=/usr
make
make install

cd /sources
rm -rf xfwm4-4.20.0
echo "==> Xfwm4 klaar"
