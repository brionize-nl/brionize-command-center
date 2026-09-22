#!/bin/bash
# BLFS 12.4 — GSettings-Desktop-Schemas-48.0. Draait binnen chroot, als
# root. Runtime-dependency van at-spi2-core; Required: GLib (aanwezig).
set -euo pipefail
cd /sources
tar -xf gsettings-desktop-schemas-48.0.tar.xz
cd gsettings-desktop-schemas-48.0

sed -i -r 's:"(/system):"/org/gnome\1:g' schemas/*.in

mkdir build
cd build

meson setup --prefix=/usr --buildtype=release ..
ninja
ninja install

cd /sources
rm -rf gsettings-desktop-schemas-48.0
echo "==> GSettings-Desktop-Schemas klaar"
