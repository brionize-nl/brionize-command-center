#!/bin/bash
# Draait als lfs-gebruiker. Downloadt en verifieert (md5) de pakketten die
# LFS 12.4 hoofdstuk 6 (temporary tools) nodig heeft. Bron: officiële LFS
# 12.4 wget-list/md5sums.
source "$(dirname "$0")/../01-toolchain/env.sh"
source "$(dirname "$0")/../lib/fetch-verified.sh"

cd "$LFS/sources"

declare -A URLS=(
  [m4-1.4.20.tar.xz]="https://ftp.gnu.org/gnu/m4/m4-1.4.20.tar.xz"
  [ncurses-6.5-20250809.tgz]="https://invisible-mirror.net/archives/ncurses/current/ncurses-6.5-20250809.tgz"
  [bash-5.3.tar.gz]="https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz"
  [coreutils-9.7.tar.xz]="https://ftp.gnu.org/gnu/coreutils/coreutils-9.7.tar.xz"
  [diffutils-3.12.tar.xz]="https://ftp.gnu.org/gnu/diffutils/diffutils-3.12.tar.xz"
  [file-5.46.tar.gz]="https://astron.com/pub/file/file-5.46.tar.gz"
  [findutils-4.10.0.tar.xz]="https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz"
  [gawk-5.3.2.tar.xz]="https://ftp.gnu.org/gnu/gawk/gawk-5.3.2.tar.xz"
  [grep-3.12.tar.xz]="https://ftp.gnu.org/gnu/grep/grep-3.12.tar.xz"
  [gzip-1.14.tar.xz]="https://ftp.gnu.org/gnu/gzip/gzip-1.14.tar.xz"
  [make-4.4.1.tar.gz]="https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
  [patch-2.8.tar.xz]="https://ftp.gnu.org/gnu/patch/patch-2.8.tar.xz"
  [sed-4.9.tar.xz]="https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz"
  [tar-1.35.tar.xz]="https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz"
  [xz-5.8.1.tar.xz]="https://github.com//tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.xz"
  [Python-3.13.7.tar.xz]="https://www.python.org/ftp/python/3.13.7/Python-3.13.7.tar.xz"
  [bison-3.8.2.tar.xz]="https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz"
  [gettext-0.26.tar.xz]="https://ftp.gnu.org/gnu/gettext/gettext-0.26.tar.xz"
  [perl-5.42.0.tar.xz]="https://www.cpan.org/src/5.0/perl-5.42.0.tar.xz"
  [texinfo-7.2.tar.xz]="https://ftp.gnu.org/gnu/texinfo/texinfo-7.2.tar.xz"
  [util-linux-2.41.1.tar.xz]="https://www.kernel.org/pub/linux/utils/util-linux/v2.41/util-linux-2.41.1.tar.xz"
)

declare -A MD5=(
  [m4-1.4.20.tar.xz]="6eb2ebed5b24e74b6e890919331d2132"
  [ncurses-6.5-20250809.tgz]="679987405412f970561cc85e1e6428a2"
  [bash-5.3.tar.gz]="977c8c0c5ae6309191e7768e28ebc951"
  [coreutils-9.7.tar.xz]="6b7285faf7d5eb91592bdd689270d3f1"
  [diffutils-3.12.tar.xz]="d1b18b20868fb561f77861cd90b05de4"
  [file-5.46.tar.gz]="459da2d4b534801e2e2861611d823864"
  [findutils-4.10.0.tar.xz]="870cfd71c07d37ebe56f9f4aaf4ad872"
  [gawk-5.3.2.tar.xz]="b7014650c5f45e5d4837c31209dc0037"
  [grep-3.12.tar.xz]="5d9301ed9d209c4a88c8d3a6fd08b9ac"
  [gzip-1.14.tar.xz]="4bf5a10f287501ee8e8ebe00ef62b2c2"
  [make-4.4.1.tar.gz]="c8469a3713cbbe04d955d4ae4be23eeb"
  [patch-2.8.tar.xz]="149327a021d41c8f88d034eab41c039f"
  [sed-4.9.tar.xz]="6aac9b2dbafcd5b7a67a8a9bcb8036c3"
  [tar-1.35.tar.xz]="a2d8042658cfd8ea939e6d911eaf4152"
  [xz-5.8.1.tar.xz]="cf5e1feb023d22c6bdaa30e84ef3abe3"
  [Python-3.13.7.tar.xz]="256cdb3bbf45cdce7499e52ba6c36ea3"
  [bison-3.8.2.tar.xz]="c28f119f405a2304ff0a7ccdcc629713"
  [gettext-0.26.tar.xz]="8e14e926f088e292f5f2bce95b81d10e"
  [perl-5.42.0.tar.xz]="7a6950a9f12d01eb96a9d2ed2f4e0072"
  [texinfo-7.2.tar.xz]="11939a7624572814912a18e76c8d8972"
  [util-linux-2.41.1.tar.xz]="7e5e68845e2f347cf96f5448165f1764"
)

for f in "${!URLS[@]}"; do
  fetch_verified "$f" "${URLS[$f]}" "${MD5[$f]}" || exit 1
done

echo "==> Alle hoofdstuk-6/7-bronnen aanwezig en geverifieerd"
