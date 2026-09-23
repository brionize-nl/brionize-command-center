#!/bin/bash
# BLFS 12.4 — Xfdesktop-4.20.1. Draait binnen chroot, als root.
# Required: Exo, libxfce4windowing, libwnck — allemaal al aanwezig.
# Aanbevolen: libnotify (00h), startup-notification (00d), Thunar
# (vorige stappen).
set -euo pipefail
cd /sources
tar -xf xfdesktop-4.20.1.tar.bz2
cd xfdesktop-4.20.1

./configure --prefix=/usr
make
make install

cd /sources
rm -rf xfdesktop-4.20.1
echo "==> Xfdesktop klaar"
