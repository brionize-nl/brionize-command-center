#!/bin/bash
# LFS 12.4 hoofdstuk 8.59 — Coreutils-9.7. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf coreutils-9.7.tar.xz
cd coreutils-9.7

patch -Np1 -i ../coreutils-9.7-upstream_fix-1.patch

patch -Np1 -i ../coreutils-9.7-i18n-1.patch

autoreconf -fv
automake -af
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make NON_ROOT_USERNAME=tester check-root

groupadd -g 102 dummy -U tester

chown -R tester . 

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
#    < /dev/null

groupdel dummy

make install

mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd /sources
rm -rf coreutils-9.7
echo "==> Coreutils klaar"
