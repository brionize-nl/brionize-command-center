#!/bin/bash
# BLFS 12.4 — libxfce4util-4.20.1. Draait binnen chroot, als root.
# Required: GLib met GObject Introspection (aanwezig uit 03b). Eerste
# pakket van de XFCE-core-keten — alle andere 16 hangen hier direct of
# indirect van af.
set -euo pipefail
cd /sources
tar -xf libxfce4util-4.20.1.tar.bz2
cd libxfce4util-4.20.1

./configure --prefix=/usr
make
make install

cd /sources
rm -rf libxfce4util-4.20.1
echo "==> libxfce4util klaar"
