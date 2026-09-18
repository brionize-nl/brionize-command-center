#!/bin/bash
# LFS 12.4 — GCC-15.2.0 Pass 2 (hoofdstuk 6, laatste stap). Draait als
# lfs-gebruiker. Na deze stap is het tijdelijke systeem "self-hosting"
# genoeg om naar chroot over te gaan (hoofdstuk 7).
source "$(dirname "$0")/../01-toolchain/env.sh"

cd "$LFS/sources"
tar -xf gcc-15.2.0.tar.xz
cd gcc-15.2.0

tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir -v build
cd build

../configure \
    --build=$(../config.guess) \
    --host="$LFS_TGT" \
    --target="$LFS_TGT" \
    --prefix=/usr \
    --with-build-sysroot="$LFS" \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-multilib \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libsanitizer \
    --disable-libssp \
    --disable-libvtv \
    --enable-languages=c,c++ \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc

make
make DESTDIR="$LFS" install
ln -sv gcc "$LFS/usr/bin/cc"

cd "$LFS/sources"
rm -rf gcc-15.2.0
echo "==> GCC Pass 2 klaar — hoofdstuk 6 (temporary tools) compleet"
