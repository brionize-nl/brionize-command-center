#!/bin/bash
# LFS 12.4 hoofdstuk 8.28 — Shadow-4.18.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf shadow-4.18.0.tar.xz
cd shadow-4.18.0

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs

touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32

make

make exec_prefix=/usr install
make -C man install-man

pwconv

grpconv

mkdir -p /etc/default
useradd -D --gid 999

sed -i '/MAIL/s/yes/no/' /etc/default/useradd

# Het boek laat je hier interactief 'passwd root' draaien — dat blokkeert
# in een niet-interactieve build (CI heeft geen terminal om een wachtwoord
# in te typen). Grondregel van dit project: nooit hardcoded secrets/
# wachtwoorden in de repo, dus we zetten hier ook geen placeholder-
# wachtwoord. In plaats daarvan blijft het root-account gewoon vergrendeld
# (geen geldig wachtwoord) — de first-boot wizard op de doel-pc regelt de
# echte gebruikers-/wachtwoordinstelling (zie BLUEPRINT.md).
passwd -l root

cd /sources
rm -rf shadow-4.18.0
echo "==> Shadow klaar"
