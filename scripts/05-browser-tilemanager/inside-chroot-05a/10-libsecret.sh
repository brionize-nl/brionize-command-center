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
#
# '-D vapi=false' — zesde CI-run (2026-09-26) faalde vervolgens op
# "Program 'vapigen' not found" (Vala-bindings-generator, standaard
# 'true'). We bouwen nergens Vala/vapigen in deze keten en hebben er
# ook verder geen gebruik voor — uitschakelen i.p.v. het toevoegen van
# een Vala-toolchain enkel voor deze ene optionele binding.
#
# '-D manpage=false' — proactief uitgeschakeld (nog niet als CI-fout
# gezien, wel bevestigd via de echte bron: `docs/man/meson.build`
# haalt tijdens de build een docbook.xsl-stylesheet op van
# http://docbook.sourceforge.net/... via xsltproc). Fase 5's
# `run-all.sh` kopieert (nog) geen /etc/resolv.conf naar de chroot
# (anders dan fase 4's run-all.sh) en het is sowieso fragiel om een
# build afhankelijk te maken van een externe netwerk-fetch tijdens
# CI — vermeden i.p.v. afgewacht tot dit alsnog faalt.
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
    -D vapi=false       \
    -D manpage=false    \
    ..
ninja
ninja install

cd /sources
rm -rf libsecret-0.21.7
echo "==> libsecret klaar"
