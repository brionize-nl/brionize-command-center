#!/bin/bash
# BLFS 12.4 — unifdef-2.12. Draait binnen chroot, als root. Geen
# dependencies. Nodig voor WebKitGTK's buildsysteem (preprocessor-
# code verwijderen). Twee boek-sed-fixes: gcc-15-compatibiliteit
# ("constexpr" is nu een reserved keyword) en een herinstallatie-fix.
set -euo pipefail
cd /sources
tar -xf unifdef-2.12.tar.gz
cd unifdef-2.12

sed -i 's/constexpr/unifdef_&/g' unifdef.c
sed -i 's/ln -s/ln -sf/' Makefile

make
make prefix=/usr install

cd /sources
rm -rf unifdef-2.12
echo "==> unifdef klaar"
