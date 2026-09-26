#!/bin/bash
# BLFS 12.4 — libsecret-0.21.7. Draait binnen chroot, als root.
# Required: GLib (03b). Nodig voor WebKitGTK (credential-opslag).
# '-D gtk_doc=false' — boek-standaard, geen documentatietools gebouwd.
# NB: runtime hoort hier gnome-keyring bij (boek: "Required Runtime
# Dependency") — niet gebouwd, geen wachtwoordkluis-backend dus nog;
# dit blokkeert de BUILD niet, alleen een toekomstige runtime-feature.
#
# '-D crypto=gnutls' — vijfde CI-run (2026-09-26) faalde hier hard:
# "Dependency 'libgcrypt' not found" (meson's standaardkeuze voor de
# 'crypto'-optie is 'libgcrypt', niet optioneel met fallback zoals
# eerder aangenomen). libsecret's eigen meson_options.txt biedt zelf
# een 'gnutls'-alternatief voor exact deze transport-encryptie-taak —
# en GnuTLS-3.8.10 staat al eerder in onze eigen keten (03-gnutls.sh).
# Hergebruik i.p.v. een 20e los systeempakket (libgcrypt) toevoegen.
set -euo pipefail
cd /sources
tar -xf libsecret-0.21.7.tar.xz
cd libsecret-0.21.7

mkdir bld
cd bld

meson setup --prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false    \
    -D crypto=gnutls    \
    ..
ninja
ninja install

cd /sources
rm -rf libsecret-0.21.7
echo "==> libsecret klaar"
