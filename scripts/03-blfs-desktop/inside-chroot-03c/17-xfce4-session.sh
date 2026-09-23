#!/bin/bash
# BLFS 12.4 — xfce4-session-4.20.3. Draait binnen chroot, als root.
# Laatste stap van fase 3c. Required: libwnck, libxfce4windowing,
# libxfce4ui — allemaal al aanwezig. Required (runtime): Xfdesktop
# (vorige stap). Aanbevolen: desktop-file-utils (00f), shared-mime-info
# (uit 03b). '--disable-legacy-sm' (boek default) — geen legacy
# session-management nodig.
set -euo pipefail
cd /sources
tar -xf xfce4-session-4.20.3.tar.bz2
cd xfce4-session-4.20.3

./configure --prefix=/usr       \
    --sysconfdir=/etc   \
    --disable-legacy-sm
make
make install

cd /sources
rm -rf xfce4-session-4.20.3
echo "==> xfce4-session klaar — fase 3c (XFCE-core) compleet"
