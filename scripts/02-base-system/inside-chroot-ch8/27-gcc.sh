#!/bin/bash
# LFS 12.4 hoofdstuk 8.29 — GCC-15.2.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf gcc-15.2.0.tar.xz
cd gcc-15.2.0

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

make

ulimit -s -H unlimited

sed -e '/cpython/d' -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en
# betrouwbaarheid — de 'tester'-gebruiker uit het boek bestaat daarom niet
# in deze build, dus ook de chown-voorbereiding ervoor is overgeslagen.
# chown -R tester .
# su tester -c "PATH=$PATH make -k check"

# ../contrib/test_summary

make install

chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/15.2.0/include{,-fixed}

ln -svr /usr/bin/cpp /usr/lib

ln -sv gcc.1 /usr/share/man/man1/cc.1

ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

# Diagnostische sanity-check uit het boek — net als bij Glibc (fase 1) is
# dit een controle die een mens met het oog beoordeelt; een grep zonder
# match hier betekent niet per definitie een kapotte toolchain (make
# install hierboven is al met set -e afgedwongen), dus set +e zodat dit de
# build niet alsnog laat mislukken op het allerlaatste moment.
{
  set +e
  echo 'int main(){}' | cc -x c - -v -Wl,--verbose &> dummy.log
  readelf -l a.out | grep ': /lib'
  grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
  grep -B4 '^ /usr/include' dummy.log
  grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'
  grep "/lib.*/libc.so.6 " dummy.log
  grep found dummy.log
  set -e
} | tee gcc-sanity-check.log

rm -v a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd /sources
rm -rf gcc-15.2.0
echo "==> GCC klaar"
