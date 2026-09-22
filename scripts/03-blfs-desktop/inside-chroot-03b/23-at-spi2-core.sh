#!/bin/bash
# BLFS 12.4 — At-Spi2 Core-2.56.4. Draait binnen chroot, als root.
# Required: dbus, GLib, Xorg Libraries — allemaal al aanwezig.
# '-D gtk2_atk_adaptor=false' (geen GTK2), '-D systemd_user_dir=/tmp'
# (geen systemd/logind) — letterlijk het boek's eigen standaardcommando.
set -euo pipefail
cd /sources
tar -xf at-spi2-core-2.56.4.tar.xz
cd at-spi2-core-2.56.4

mkdir build
cd build

meson setup ..                  \
    --prefix=/usr             \
    --buildtype=release       \
    -D gtk2_atk_adaptor=false \
    -D systemd_user_dir=/tmp
ninja
ninja install
rm -f /tmp/at-spi-dbus-bus.service

cd /sources
rm -rf at-spi2-core-2.56.4
echo "==> At-Spi2 Core klaar"
