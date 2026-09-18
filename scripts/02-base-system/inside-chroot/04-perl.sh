#!/bin/bash
# LFS 12.4 hoofdstuk 7.9 — Perl-5.42.0. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf perl-5.42.0.tar.xz
cd perl-5.42.0

sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.42/core_perl     \
             -D archlib=/usr/lib/perl5/5.42/core_perl     \
             -D sitelib=/usr/lib/perl5/5.42/site_perl     \
             -D sitearch=/usr/lib/perl5/5.42/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl

make
make install

cd /sources
rm -rf perl-5.42.0
echo "==> Perl klaar"
