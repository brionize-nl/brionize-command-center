#!/bin/bash
# BLFS 12.4 — Tumbler-4.20.0. Draait binnen chroot, als root.
# Required: GLib (aanwezig). Verwijdert een systemd-user-unit na
# installatie (boek-instructie, we hebben geen systemd).
set -euo pipefail
cd /sources
tar -xf tumbler-4.20.0.tar.bz2
cd tumbler-4.20.0

./configure --prefix=/usr --sysconfdir=/etc
make
make install
rm -fv /usr/lib/systemd/user/tumblerd.service

cd /sources
rm -rf tumbler-4.20.0
echo "==> Tumbler klaar"
