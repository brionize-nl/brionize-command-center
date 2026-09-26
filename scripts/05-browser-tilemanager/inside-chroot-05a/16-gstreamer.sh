#!/bin/bash
# BLFS 12.4 — gstreamer-1.26.5. Draait binnen chroot, als root.
# Required: GLib (03b). Nodig voor gst-plugins-base (uiteindelijk
# WebKitGTK, HTML5-audio/video). '-D gst_debug=false' (boek-standaard)
# — geen debug-logging-overhead.
set -euo pipefail
cd /sources
tar -xf gstreamer-1.26.5.tar.xz
cd gstreamer-1.26.5

mkdir build
cd build

meson setup ..            \
    --prefix=/usr       \
    --buildtype=release \
    -D gst_debug=false
ninja
ninja install

cd /sources
rm -rf gstreamer-1.26.5
echo "==> gstreamer klaar"
