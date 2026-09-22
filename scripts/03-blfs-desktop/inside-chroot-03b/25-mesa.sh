#!/bin/bash
# BLFS 12.4 — Mesa-25.1.8. Draait binnen chroot, als root.
# Zie Beslislog (2026-09-22) en BLUEPRINT.md "Dependency-audit fase
# 3b/3c" voor de volledige onderbouwing: GTK3 vereist via libepoxy
# hard Mesa. Bewust MINIMAAL t.o.v. het boek's standaard 'auto'
# (bouwt anders drivers voor ALLE GPU-merken):
# - '-D gallium-drivers=llvmpipe' — alleen de CPU-software-rasterizer,
#   geen hardware-GPU-vendor-drivers. Houdt de "generieke hardware,
#   geen GPU-driver-afhankelijkheid"-doelstelling overeind.
# - '-D platforms=x11' — geen wayland (XFCE draait hier op X11; scheelt
#   de hele wayland/wayland-protocols-afhankelijkheidsketen).
# - '-D vulkan-drivers=' (leeg) — geen Vulkan nodig voor een
#   software-only, X11-only desktop.
# xorg-server's eigen '-D glamor=false -D glx=false' (03a) blijft
# ONGEWIJZIGD — Mesa komt er via GTK3/libepoxy bij, niet om alsnog
# GPU-versnelde Xorg-compositing te activeren.
set -euo pipefail
cd /sources
tar -xf mesa-25.1.8.tar.xz
cd mesa-25.1.8

mkdir build
cd build

meson setup ..                 \
    --prefix=/usr    \
    --buildtype=release      \
    -D platforms=x11         \
    -D gallium-drivers=llvmpipe \
    -D vulkan-drivers=        \
    -D valgrind=disabled     \
    -D libunwind=disabled
ninja
ninja install

cd /sources
rm -rf mesa-25.1.8
echo "==> Mesa (llvmpipe-only) klaar"
