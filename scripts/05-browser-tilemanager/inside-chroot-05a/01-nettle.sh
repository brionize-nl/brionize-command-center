#!/bin/bash
# BLFS 12.4 — Nettle-3.10.2. Draait binnen chroot, als root. Geen
# dependencies buiten wat al aanwezig is. Nodig voor GnuTLS.
set -euo pipefail
cd /sources
tar -xf nettle-3.10.2.tar.gz
cd nettle-3.10.2

./configure --prefix=/usr --disable-static
make
make install
chmod -v 755 /usr/lib/lib{hogweed,nettle}.so

cd /sources
rm -rf nettle-3.10.2
echo "==> Nettle klaar"
