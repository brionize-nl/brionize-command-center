#!/bin/bash
# BLFS 12.4 — libxml2-2.14.5. Draait binnen chroot, als root.
# Nodig voor shared-mime-info. AFWIJKING t.o.v. het boek: geen
# '--with-icu' — het boek zet dit standaard aan, maar ICU is bewust
# NIET gebouwd (alleen "Recommended", groot pakket, niet nodig voor
# onze doelen). Zonder ICU aanwezig zou '--with-icu' de configure laten
# falen; zonder de vlag detecteert configure gewoon dat ICU ontbreekt
# en bouwt zonder ICU-integratie (functioneel voldoende hier).
set -euo pipefail
cd /sources
tar -xf libxml2-2.14.5.tar.xz
cd libxml2-2.14.5

./configure --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    --with-history    \
    PYTHON=/usr/bin/python3 \
    --docdir=/usr/share/doc/libxml2-2.14.5
make
make install

cd /sources
rm -rf libxml2-2.14.5
echo "==> libxml2 klaar"
