#!/bin/bash
# devilspie2-0.36. Draait binnen chroot, als root. Niet in BLFS —
# officiële GitHub-tag van de hoofdontwikkelaar (gusnan/devilspie2).
# Vereist (uit het eigen Makefile, pkg-config-namen letterlijk
# nagekeken): gtk+-3.0 (03b), libwnck-3.0 (03c, geleverd door
# libwnck-43.2), lua (deze fase, 01-lua.sh), libX11 (03a). Eigen
# Makefile gebruikt PREFIX i.p.v. een configure-script.
#
# Bron-compatibiliteitsfix (echte build-fout, niet gegokt): devilspie2
# dateert uit het Lua-5.1-tijdperk en gebruikt de macro LUA_QL(), die
# sinds Lua 5.3 niet meer bestaat (wij bouwen tegen Lua 5.4.8, hierboven
# in 01-lua.sh). LUA_QL(x) breidde vroeger simpelweg uit naar "'" x "'"
# — hier letterlijk zo vervangen, de enige twee aanroepen in de hele
# broncode (src/script_functions.c, geverifieerd met grep).
set -euo pipefail
cd /sources
tar -xf devilspie2-0.36.tar.gz
cd devilspie2-0.36

sed -i \
  -e "s/LUA_QL(\"tostring\")/\"'tostring'\"/" \
  -e "s/LUA_QL(\"print\")/\"'print'\"/" \
  src/script_functions.c

make PREFIX=/usr
make PREFIX=/usr install

cd /sources
rm -rf devilspie2-0.36
echo "==> devilspie2 klaar"
