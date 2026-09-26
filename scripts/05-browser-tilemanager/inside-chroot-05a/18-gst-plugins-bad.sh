#!/bin/bash
# BLFS 12.4 — gst-plugins-bad-1.26.5. Draait binnen chroot, als root.
# Required: gst-plugins-base (vorige stap). De hele lange Optional-
# lijst (opencv/x265/libaom/etc.) bewust niet meegenomen — WebKitGTK
# heeft alleen deze batch-package zelf aanwezig nodig.
# '-D gpl=enabled' (boek-standaard) — schakelt GPL-gelicenseerde
# plugins in de batch in (geen van de zware Optional-codecs die we
# toch niet bouwen).
set -euo pipefail
cd /sources
tar -xf gst-plugins-bad-1.26.5.tar.xz
cd gst-plugins-bad-1.26.5

mkdir build
cd build

meson setup ..            \
    --prefix=/usr       \
    --buildtype=release \
    -D gpl=enabled
ninja
ninja install

cd /sources
rm -rf gst-plugins-bad-1.26.5
echo "==> gst-plugins-bad klaar"
