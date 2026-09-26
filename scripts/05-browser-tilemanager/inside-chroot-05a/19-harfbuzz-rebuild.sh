#!/bin/bash
# BLFS 12.4 — HarfBuzz-11.4.1, HERBOUW binnen fase 5a. Draait binnen
# chroot, als root.
#
# HarfBuzz werd oorspronkelijk in fase 3b gebouwd, TOEN ICU nog niet
# bestond (ICU wordt pas in fase 5a stap 08 gebouwd). HarfBuzz's eigen
# meson-optie 'icu' staat standaard op 'auto' en detecteerde ICU dus
# als afwezig — de ICU-integratie (hb-icu.h + de 'harfbuzz-icu'-
# pkgconfig-module) werd daardoor nooit gebouwd.
#
# Ontdekt via lokale audit van WebKitGTK's eigen bron
# (Source/cmake/OptionsGTK.cmake: 'find_package(HarfBuzz 2.7.4
# REQUIRED COMPONENTS ICU)', Source/cmake/FindHarfBuzz.cmake zoekt
# expliciet naar een apart 'harfbuzz-icu'-pkgconfig-bestand) — NIET
# afgewacht tot een volgende CI-failure dit zou bevestigen. Zelfde
# herbouw-patroon als eerder in dit project: freetype/fontconfig-
# herbouw ná HarfBuzz (fase 3b, 15/16-*-rebuild.sh) en Python-herbouw
# ná SQLite (fase 4, 09-python-rebuild-sqlite3.sh).
#
# De originele harfbuzz-11.4.1.tar.xz staat nog in /sources (fase 3b
# verwijderde alleen de uitgepakte bouwmap, niet de tarball zelf, en
# $LFS wordt als volledige boom tussen alle CI-cache-lagen doorgegeven)
# — geen nieuwe fetch_verified()-aanroep nodig.
set -euo pipefail
cd /sources
tar -xf harfbuzz-11.4.1.tar.xz
cd harfbuzz-11.4.1

mkdir build
cd build

meson setup ..              \
    --prefix=/usr          \
    --buildtype=release    \
    -D graphite2=disabled  \
    -D icu=enabled
ninja
ninja install

cd /sources
rm -rf harfbuzz-11.4.1
echo "==> HarfBuzz (met ICU-integratie) herbouwd"
