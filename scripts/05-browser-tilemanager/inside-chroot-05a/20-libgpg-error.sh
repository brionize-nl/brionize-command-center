#!/bin/bash
# BLFS 12.4 — libgpg-error-1.55. Draait binnen chroot, als root. Geen
# harde dependencies. Nodig voor libgcrypt (volgende stap), die weer
# nodig is voor WebKitGTK's eigen hard vereiste "LibGcrypt"-check
# (Source/cmake/OptionsGTK.cmake: 'find_package(LibGcrypt 1.7.0
# REQUIRED)', ontdekt via de zevende CI-run (2026-09-26:
# "Could NOT find LibGcrypt") + lokale audit van de echte
# cmake-bronbestanden). Niet in de oorspronkelijke 19-pakketten-audit
# — WebKitGTK's eigen BLFS-paginalijst noemt dit niet apart, vermoedelijk
# omdat een volledige BLFS-boekvolgorde libgcrypt al eerder bouwt; onze
# afwijkende (minimale) opbouw miste het daardoor.
set -euo pipefail
cd /sources
tar -xf libgpg-error-1.55.tar.bz2
cd libgpg-error-1.55

./configure --prefix=/usr
make
make install

cd /sources
rm -rf libgpg-error-1.55
echo "==> libgpg-error klaar"
