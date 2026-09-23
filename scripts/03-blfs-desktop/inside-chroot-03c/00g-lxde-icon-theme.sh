#!/bin/bash
# BLFS 12.4 — LXDE Icon Theme-0.5.1. Draait binnen chroot, als root.
# Runtime-dependency van xfce4-settings (of gnome-icon-theme — hier
# bewust de lichtere LXDE-variant gekozen, zelfde minimale-footprint-
# keuze als eerder bij Mesa/llvmpipe).
set -euo pipefail
cd /sources
tar -xf lxde-icon-theme-0.5.1.tar.xz
cd lxde-icon-theme-0.5.1

./configure --prefix=/usr
make install

cd /sources
rm -rf lxde-icon-theme-0.5.1
echo "==> LXDE Icon Theme klaar"
