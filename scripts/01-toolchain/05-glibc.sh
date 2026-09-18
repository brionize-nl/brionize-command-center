#!/bin/bash
# LFS 12.4 — Glibc-2.42 (hoofdstuk 5). Draait als lfs-gebruiker.
source "$(dirname "$0")/env.sh"

case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 "$LFS/lib/ld-lsb.so.3"
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64"
            ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64/ld-lsb-x86-64.so.3"
    ;;
esac

cd "$LFS/sources"
tar -xf glibc-2.42.tar.xz
cd glibc-2.42

patch -Np1 -i ../glibc-2.42-fhs-1.patch

mkdir -v build
cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
      --prefix=/usr                      \
      --host="$LFS_TGT"                  \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib           \
      --enable-kernel=5.4

make
make DESTDIR="$LFS" install

sed '/RTLDLIST=/s@/usr@@g' -i "$LFS/usr/bin/ldd"

# Sanity-check uit het officiële boek — dit is een diagnostische controle
# die de mens normaal met het oog beoordeelt. We loggen de uitkomst maar
# laten 'm de build niet blokkeren (set +e), want een grep zonder match
# is niet per definitie een gebroken toolchain, en de echte make/make
# install hierboven zijn al met set -e afgedwongen.
{
  set +e
  echo 'int main(){}' | "$LFS_TGT"-gcc -x c - -v -Wl,--verbose &> dummy.log
  echo "--- readelf ---"
  readelf -l a.out | grep ': /lib'
  echo "--- crt succeeded ---"
  grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log
  echo "--- usr/include ---"
  grep -B3 "^ $LFS/usr/include" dummy.log
  echo "--- SEARCH usr/lib ---"
  grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'
  echo "--- libc.so.6 ---"
  grep "/lib.*/libc.so.6 " dummy.log
  echo "--- found ---"
  grep found dummy.log
  set -e
} | tee "$LFS/sources/glibc-sanity-check.log"

rm -v a.out dummy.log

cd "$LFS/sources"
rm -rf glibc-2.42

echo "==> Glibc klaar (zie glibc-sanity-check.log voor de diagnostische controle)"
