#!/bin/bash
# BLFS 12.4 — libgcrypt-1.11.2. Draait binnen chroot, als root.
# Required: libgpg-error (vorige stap). Optional (texlive, voor de
# HTML/texinfo-documentatie) bewust niet gebouwd — alleen de kern
# `./configure && make && make install` van het boek, geen
# 'make -C doc html'/makeinfo-documentatiestappen (we hebben geen
# texlive en hebben de documentatie niet nodig). Nodig voor
# WebKitGTK's eigen hard vereiste "LibGcrypt"-check (zie
# 20-libgpg-error.sh voor de volledige toedracht).
set -euo pipefail
cd /sources
tar -xf libgcrypt-1.11.2.tar.bz2
cd libgcrypt-1.11.2

./configure --prefix=/usr
make
make install

cd /sources
rm -rf libgcrypt-1.11.2
echo "==> libgcrypt klaar"
