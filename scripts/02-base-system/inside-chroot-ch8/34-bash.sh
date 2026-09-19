#!/bin/bash
# LFS 12.4 hoofdstuk 8.36 — Bash-5.3. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf bash-5.3.tar.gz
cd bash-5.3

./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid
# ('tester'-gebruiker bestaat daarom niet, dus ook de chown ervoor overgeslagen).
# chown -R tester .
# LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"
# set timeout -1
# spawn make tests
# expect eof
# lassign [wait] _ _ _ value
# exit $value
# EOF

make install

# Geen interactieve exec /usr/bin/bash --login: run-all.sh start elke volgende stap met de nieuw geïnstalleerde bash.

cd /sources
rm -rf bash-5.3
echo "==> Bash klaar"
