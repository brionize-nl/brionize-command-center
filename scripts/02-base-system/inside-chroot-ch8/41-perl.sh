#!/bin/bash
# LFS 12.4 hoofdstuk 8.43 — Perl-5.42.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf perl-5.42.0.tar.xz
cd perl-5.42.0

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.42/core_perl      \
             -D archlib=/usr/lib/perl5/5.42/core_perl      \
             -D sitelib=/usr/lib/perl5/5.42/site_perl      \
             -D sitearch=/usr/lib/perl5/5.42/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# TEST_JOBS=$(nproc) make test_harness

make install
unset BUILD_ZLIB BUILD_BZIP2

cd /sources
rm -rf perl-5.42.0
echo "==> Perl klaar"
