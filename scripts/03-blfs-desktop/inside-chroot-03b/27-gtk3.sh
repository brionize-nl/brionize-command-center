#!/bin/bash
# BLFS 12.4 — GTK3-3.24.50. Draait binnen chroot, als root.
# Laatste stap van fase 3b. Required: at-spi2-core, gdk-pixbuf,
# libepoxy, Pango — allemaal al aanwezig. Effectief ook vereist:
# GLib-met-introspectie (aanwezig sinds stap 07-09).
#
# '-D wayland_backend=false' — AFWIJKING t.o.v. het boek (dat deze vlag
# niet zet). GTK3's eigen 'wayland_backend'-optie is een gewone boolean
# die op Linux standaard OP staat (géén 'auto'-detectie op basis van
# aanwezige wayland-bibliotheken!) — meson.build:441 maakt xkbcommon
# dan verplicht ("required: wayland_enabled"), wat faalt omdat we bewust
# geen wayland/wayland-protocols/libxkbcommon gebouwd hebben (X11-only-
# doel). Het boek's eigen voorbeeldcommando gaat er stilzwijgend van uit
# dat je de "Recommended" wayland-stack al hebt; wij niet.
#
# '-D man=false' (i.p.v. het boek's 'man=true') — GTK3's man-pages
# gebruiken xsltproc (uit libxslt), NIET rst2man/docutils zoals GLib en
# gdk-pixbuf: "No xsltproc found, but man pages were explicitly
# enabled" (docs/reference/gtk/meson.build:488). Weer een ANDER
# doc-toolchain-pakket niet gebouwd (bewust) — geen man-pages nodig
# voor een werkend systeem.
set -euo pipefail
cd /sources
tar -xf gtk-3.24.50.tar.xz
cd gtk-3.24.50

mkdir build
cd build

meson setup ..                  \
    --prefix=/usr             \
    --buildtype=release       \
    -D wayland_backend=false  \
    -D man=false              \
    -D broadway_backend=true
ninja
ninja install

cd /sources
rm -rf gtk-3.24.50
echo "==> GTK3 klaar — fase 3b (GTK3-supporting-stack) compleet"
