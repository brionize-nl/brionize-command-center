#!/bin/bash
# LFS 12.4 hoofdstuk 8.41 — Inetutils-2.6. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf inetutils-2.6.tar.xz
cd inetutils-2.6

sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

mv -v /usr/{,s}bin/ifconfig

cd /sources
rm -rf inetutils-2.6
echo "==> Inetutils klaar"
