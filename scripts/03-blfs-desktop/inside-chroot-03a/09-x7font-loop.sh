#!/bin/bash
# BLFS 12.4 hoofdstuk "Xorg Fonts" (x7font.html) — 9 pakketten, generieke
# lus (geen uitzonderingen). Draait binnen chroot, als root.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources

packages="font-util-1.4.1.tar.xz encodings-1.1.0.tar.xz font-alias-1.0.5.tar.xz \
font-adobe-utopia-type1-1.0.5.tar.xz font-bh-ttf-1.0.4.tar.xz \
font-bh-type1-1.0.4.tar.xz font-ibm-type1-1.0.4.tar.xz \
font-misc-ethiopic-1.0.5.tar.xz font-xfree86-type1-1.0.5.tar.xz"

for package in $packages; do
  packagedir=${package%.tar.?z*}
  echo "==> Building $packagedir"
  tar -xf $package
  pushd $packagedir
    ./configure $XORG_CONFIG
    make
    make install
  popd
  rm -rf $packagedir
done

install -v -d -m755 /usr/share/fonts
ln -svfn $XORG_PREFIX/share/fonts/X11/OTF /usr/share/fonts/X11-OTF
ln -svfn $XORG_PREFIX/share/fonts/X11/TTF /usr/share/fonts/X11-TTF

echo "==> Xorg-fonts (x7font) klaar"
