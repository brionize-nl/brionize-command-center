#!/bin/bash
# BLFS 12.4 — D-Bus-1.16.2. Draait binnen chroot, als root.
# Nodig voor at-spi2-core. '-D systemd=disabled' — we hebben geen
# systemd/logind (hoofdstuk 8 bouwde alleen udev).
set -euo pipefail
cd /sources
tar -xf dbus-1.16.2.tar.xz
cd dbus-1.16.2

mkdir build
cd build

meson setup --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
    -D systemd=disabled    \
    ..
ninja
ninja install

# Nog binnen chroot/vóór eerste boot — genereer de D-Bus-UUID zodat
# latere pakketten die D-Bus nodig hebben tijdens het bouwen geen
# waarschuwingen geven (boek-instructie, letterlijk).
dbus-uuidgen --ensure

cd /sources
rm -rf dbus-1.16.2
echo "==> D-Bus klaar"
