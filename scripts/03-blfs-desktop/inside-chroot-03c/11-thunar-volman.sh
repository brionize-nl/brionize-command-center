#!/bin/bash
# BLFS 12.4 — Thunar Volume Manager-4.20.0. Draait binnen chroot, als
# root. Required: Exo, libgudev (stap 00e) — allemaal al aanwezig.
set -euo pipefail
cd /sources
tar -xf thunar-volman-4.20.0.tar.bz2
cd thunar-volman-4.20.0

./configure --prefix=/usr
make
make install

cd /sources
rm -rf thunar-volman-4.20.0
echo "==> Thunar Volume Manager klaar"
