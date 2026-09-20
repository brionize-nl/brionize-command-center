#!/bin/bash
# BLFS 12.4 — XKeyboardConfig-2.45. Draait binnen chroot, als root.
# Verse install (geen upgrade), dus het boek's opruimblok voor <=2.44 is
# hier niet van toepassing.
set -euo pipefail
source "$(dirname "$0")/00-xorg-env.sh"
cd /sources
tar -xf xkeyboard-config-2.45.tar.xz
cd xkeyboard-config-2.45

mkdir build
cd    build
meson setup --prefix=$XORG_PREFIX --buildtype=release ..
ninja
# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# ninja test
ninja install

cd /sources
rm -rf xkeyboard-config-2.45
echo "==> XKeyboardConfig klaar"
