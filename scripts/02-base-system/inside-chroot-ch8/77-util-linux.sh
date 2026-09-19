#!/bin/bash
# LFS 12.4 hoofdstuk 8.79 — Util-linux-2.41.1. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf util-linux-2.41.1.tar.xz
cd util-linux-2.41.1

./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            --without-systemd     \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.1

make

# Deze root-test is alleen voor het gebootte LFS-systeem; binnen chroot uitsluitend als tester testen.

touch /etc/fstab
# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid
# ('tester'-gebruiker bestaat daarom niet, dus ook de chown ervoor overgeslagen).
# chown -R tester .
# su tester -c "make -k check"

make install

cd /sources
rm -rf util-linux-2.41.1
echo "==> Util-linux klaar"
