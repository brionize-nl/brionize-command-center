#!/bin/bash
# BLFS 12.4 — gst-plugins-base-1.26.5. Draait binnen chroot, als root.
# Required: gstreamer (vorige stap). Recommended (alsa-lib/libogg/
# libvorbis/wayland-protocols) bewust niet gebouwd — WebKitGTK heeft
# alleen deze BATCH-package aanwezig nodig, niet elke codec-plugin.
# Bekende, bewuste beperking: HTML5 <audio>/<video> in webapps krijgt
# hierdoor geen Ogg/Vorbis-codec-ondersteuning — niet nodig voor de
# tegel-manager/PWA-doelen (UI-rendering, geen mediaspeler).
# '--wrap-mode=nodownload' (boek-standaard).
set -euo pipefail
cd /sources
tar -xf gst-plugins-base-1.26.5.tar.xz
cd gst-plugins-base-1.26.5

mkdir build
cd build

meson setup ..               \
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nodownload
ninja
ninja install

cd /sources
rm -rf gst-plugins-base-1.26.5
echo "==> gst-plugins-base klaar"
