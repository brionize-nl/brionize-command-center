#!/bin/bash
# BLFS 12.4 — xfce4-settings-4.20.2. Draait binnen chroot, als root.
# Required: Exo, Garcon — allemaal al aanwezig. Required (runtime):
# lxde-icon-theme (stap 00g, i.p.v. gnome-icon-theme — bewuste,
# lichtere keuze). Aanbevolen: libnotify (00h) — libxklavier bewust
# niet gebouwd (geen actuele BLFS 12.4-pagina gevonden, alleen
# "Recommended", legacy X11-toetsenbordlib grotendeels vervangen door
# libxkbcommon).
set -euo pipefail
cd /sources
tar -xf xfce4-settings-4.20.2.tar.bz2
cd xfce4-settings-4.20.2

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd /sources
rm -rf xfce4-settings-4.20.2
echo "==> xfce4-settings klaar"
