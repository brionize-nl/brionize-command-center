#!/bin/bash
# Draait als lfs-gebruiker. Downloadt en verifieert (md5) exact de
# pakketten die LFS 12.4 hoofdstuk 5 nodig heeft. Bron: officiële LFS 12.4
# wget-list / md5sums (linuxfromscratch.org/lfs/view/stable/).
source "$(dirname "$0")/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  [binutils-2.45.tar.xz]="https://sourceware.org/pub/binutils/releases/binutils-2.45.tar.xz"
  [gcc-15.2.0.tar.xz]="https://ftp.gnu.org/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz"
  [mpfr-4.2.2.tar.xz]="https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.xz"
  [gmp-6.3.0.tar.xz]="https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
  [mpc-1.3.1.tar.gz]="https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
  [linux-6.16.1.tar.xz]="https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.16.1.tar.xz"
  [glibc-2.42.tar.xz]="https://ftp.gnu.org/gnu/glibc/glibc-2.42.tar.xz"
  [glibc-2.42-fhs-1.patch]="https://www.linuxfromscratch.org/patches/lfs/12.4/glibc-2.42-fhs-1.patch"
)

declare -A MD5=(
  [binutils-2.45.tar.xz]="dee5b4267e0305a99a3c9d6131f45759"
  [gcc-15.2.0.tar.xz]="b861b092bf1af683c46a8aa2e689a6fd"
  [mpfr-4.2.2.tar.xz]="7c32c39b8b6e3ae85f25156228156061"
  [gmp-6.3.0.tar.xz]="956dc04e864001a9c22429f761f2c283"
  [mpc-1.3.1.tar.gz]="5c9bc658c9fd0f940e8e3e0f09530c62"
  [linux-6.16.1.tar.xz]="32d45755e4b39d06e9be58f6817445ee"
  [glibc-2.42.tar.xz]="23c6f5a27932b435cae94e087cb8b1f5"
  [glibc-2.42-fhs-1.patch]="9a5997c3452909b1769918c759eff8a2"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle bronnen aanwezig en geverifieerd"
