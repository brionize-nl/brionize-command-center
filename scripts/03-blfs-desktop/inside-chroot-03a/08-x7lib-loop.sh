#!/bin/bash
# BLFS 12.4 hoofdstuk "Xorg Libraries" (x7lib.html) — 32 pakketten,
# generieke lus + boek-eigen uitzonderingen (libXfont2/libXt/libXpm/
# libpciaccess). Draait binnen chroot, als root.
#
# Afwijkingen t.o.v. de letterlijke boektekst, bewust en hieronder
# toegelicht:
# - Geen 'as_root'-wrapper (we draaien al als root binnen chroot).
# - Vaste pakketlijst i.p.v. een md5-heredoc parsen (bronnen zijn al door
#   fetch_verified() gedownload/geverifieerd vóór deze stap draait).
# - Geen 'ln -sv $XORG_PREFIX/... /usr/...'-compatibiliteitssymlinks aan
#   het eind: die zijn alleen nuttig bij een AFWIJKEND XORG_PREFIX; met
#   XORG_PREFIX=/usr (onze keuze, zie 00-xorg-env.sh) zouden ze
#   zelf-verwijzend zijn (/usr/lib/X11 -> /usr/lib/X11).
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources

packages="xtrans-1.6.0.tar.xz libX11-1.8.12.tar.xz libXext-1.3.6.tar.xz \
libFS-1.0.10.tar.xz libICE-1.1.2.tar.xz libSM-1.2.6.tar.xz \
libXScrnSaver-1.2.4.tar.xz libXt-1.3.1.tar.xz libXmu-1.2.1.tar.xz \
libXpm-3.5.17.tar.xz libXaw-1.0.16.tar.xz libXfixes-6.0.1.tar.xz \
libXcomposite-0.4.6.tar.xz libXrender-0.9.12.tar.xz libXcursor-1.2.3.tar.xz \
libXdamage-1.1.6.tar.xz libfontenc-1.1.8.tar.xz libXfont2-2.0.7.tar.xz \
libXft-2.3.9.tar.xz libXi-1.8.2.tar.xz libXinerama-1.1.5.tar.xz \
libXrandr-1.5.4.tar.xz libXres-1.2.2.tar.xz libXtst-1.2.5.tar.xz \
libXv-1.0.13.tar.xz libXvMC-1.0.14.tar.xz libXxf86dga-1.1.6.tar.xz \
libXxf86vm-1.1.6.tar.xz libpciaccess-0.18.1.tar.xz libxkbfile-1.1.3.tar.xz \
libxshmfence-1.3.3.tar.xz libXpresent-1.0.1.tar.xz"

for package in $packages; do
  packagedir=${package%.tar.?z*}
  echo "==> Building $packagedir"

  tar -xf $package
  pushd $packagedir
  docdir="--docdir=$XORG_PREFIX/share/doc/$packagedir"

  case $packagedir in
    libXfont2-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-devel-docs
    ;;
    libXt-[0-9]* )
      ./configure $XORG_CONFIG $docdir \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;
    libXpm-[0-9]* )
      ./configure $XORG_CONFIG $docdir --disable-open-zfile
    ;;
    libpciaccess* )
      mkdir build
      cd    build
        meson setup --prefix=$XORG_PREFIX --buildtype=release ..
        ninja
        ninja install
      popd
      rm -rf /sources/$packagedir
      ldconfig
      continue
    ;;
    * )
      ./configure $XORG_CONFIG $docdir
    ;;
  esac

  make
  make install
  popd
  rm -rf $packagedir
  ldconfig
done

echo "==> Xorg-bibliotheken (x7lib) klaar"
