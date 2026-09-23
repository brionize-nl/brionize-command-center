#!/bin/bash
# BLFS 12.4 — Lua-5.4.8. Draait binnen chroot, als root.
# Nodig voor devilspie2 (Lua-scriptregels voor window-tiling) en Conky
# (Lua-config, hard vereist door Conky's eigen CMakeLists.txt:
# "find_package(Lua "5.3" REQUIRED)"). Het boek-patroon: de
# shared_library-patch is nodig om een echte liblua.so + pkgconfig-
# bestand te krijgen (zonder patch bouwt Lua alleen een statische lib).
set -euo pipefail
cd /sources
tar -xf lua-5.4.8.tar.gz
cd lua-5.4.8

cat > lua.pc << "EOF"
V=5.4
R=5.4.8
prefix=/usr
INSTALL_BIN=${prefix}/bin
INSTALL_INC=${prefix}/include
INSTALL_LIB=${prefix}/lib
INSTALL_MAN=${prefix}/share/man/man1
INSTALL_LMOD=${prefix}/share/lua/${V}
INSTALL_CMOD=${prefix}/lib/lua/${V}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include
Name: Lua
Description: An Extensible Extension Language
Version: ${R}
Requires:
Libs: -L${libdir} -llua -lm -ldl
Cflags: -I${includedir}
EOF

patch -Np1 -i ../lua-5.4.8-shared_library-1.patch
make linux
make INSTALL_TOP=/usr                \
    INSTALL_DATA="cp -d"            \
    INSTALL_MAN=/usr/share/man/man1 \
    TO_LIB="liblua.so liblua.so.5.4 liblua.so.5.4.8" \
    install
mkdir -pv                      /usr/share/doc/lua-5.4.8
cp -v doc/*.{html,css,gif,png} /usr/share/doc/lua-5.4.8
install -v -m644 -D lua.pc /usr/lib/pkgconfig/lua.pc

cd /sources
rm -rf lua-5.4.8
echo "==> Lua klaar"
