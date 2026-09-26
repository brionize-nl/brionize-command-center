#!/bin/bash
# BLFS 12.4 — GnuTLS-3.8.10. Draait binnen chroot, als root. Required:
# Nettle + libtasn1 (beide vorige stappen — libtasn1 is een harde
# configure-vereiste, geen optionele "Recommended": eerste CI-run
# (2026-09-26) faalde hier expliciet met "Libtasn1 4.9 was not found"
# omdat libtasn1 toen nog NA GnuTLS in de volgorde stond; root-cause
# fix was herordenen, niet een configure-vlag). Nodig voor
# glib-networking (TLS-backend voor libsoup3, uiteindelijk voor
# WebKitGTK). Recommended (p11-kit) bewust niet gebouwd.
#
# Libunistring ("Recommended", alleen voor IDN/internationalisatie-
# verrijking van GnuTLS zelf) blijkt configure-technisch WEL hard
# vereist tenzij je expliciet de ingebakken kopie kiest (tweede
# CI-run, 2026-09-26: "Libunistring was not found. To use the included
# one, use --with-included-unistring"). Geen andere stap in onze
# afhankelijkheidsketen heeft libunistring nodig, dus i.p.v. er een
# 20e los systeempakket voor toe te voegen gebruiken we GnuTLS's eigen
# ingebakken-kopie-vlag — zelfde minimale-footprint-aanpak als eerder
# bij bv. de LXDE-iconenset i.p.v. de volledige gnome-icon-theme-batch.
set -euo pipefail
cd /sources
tar -xf gnutls-3.8.10.tar.xz
cd gnutls-3.8.10

./configure --prefix=/usr \
    --docdir=/usr/share/doc/gnutls-3.8.10 \
    --with-default-trust-store-pkcs11="pkcs11:" \
    --with-included-unistring
make
make install

cd /sources
rm -rf gnutls-3.8.10
echo "==> GnuTLS klaar"
