#!/bin/bash
# BLFS 12.4 — Xorg-Server-21.1.18. Draait binnen chroot, als root.
#
# Afwijking t.o.v. de letterlijke boektekst, bewust:
# - Het boek zet '-D glamor=true' (GL-versnelde compositing, nodig o.a. bij
#   moderne desktopcompositors) — dat vereist libepoxy + Mesa, welke we
#   bewust NIET meenemen in deze eerste fase-3-increment (zie BLUEPRINT.md:
#   generieke, hardware-onafhankelijke build; Mesa/LLVM is een zware,
#   losse vervolgstap). Hier dus 'glamor=false': basis/onversnelde X, werkt
#   op elke hardware zonder GPU-driver-afhankelijkheid.
# - '-D systemd_logind=true' vereist systemd-logind, dat we niet hebben
#   (hoofdstuk 8 bouwde alleen udev uit systemd's broncode, geen volledige
#   systemd/logind) — daarom 'systemd_logind=false'.
# - '-D glx=false' (boek default: true, impliciet aan). Bron: xorg-server's
#   eigen include/meson.build — "dri_dep = dependency('dri', required:
#   build_glx)" — de pkgconfig-dependency 'dri' (uit Mesa) is ALLEEN
#   verplicht wanneer GLX aan staat. Zonder Mesa (bewust, zie glamor
#   hierboven) moet GLX dus ook uit, anders faalt de meson-configure hard
#   op de ontbrekende 'dri'-pkgconfig-dependency. Gevonden door de
#   letterlijke meson.build/meson_options.txt uit de brontarball te lezen
#   (niet uit het geheugen of aannames).
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf xorg-server-21.1.18.tar.xz
cd xorg-server-21.1.18

mkdir build
cd build

meson setup .. \
  --prefix=$XORG_PREFIX \
  --localstatedir=/var \
  -D glamor=false \
  -D glx=false \
  -D systemd_logind=false \
  -D xkb_output_dir=/var/lib/xkb
ninja
ninja install

mkdir -pv /etc/X11/xorg.conf.d
install -v -d -m1777 /tmp/.{ICE,X11}-unix
cat >> /etc/sysconfig/createfiles << "EOF"
/tmp/.ICE-unix dir 1777 root root
/tmp/.X11-unix dir 1777 root root
EOF

cd /sources
rm -rf xorg-server-21.1.18
echo "==> Xorg-Server klaar — fase 3a (Xorg-basis) compleet"
