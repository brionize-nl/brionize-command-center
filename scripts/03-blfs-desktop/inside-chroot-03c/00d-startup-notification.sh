#!/bin/bash
# BLFS 12.4 — startup-notification-0.12. Draait binnen chroot, als root.
# Required: Xorg Libraries + xcb-util (beide uit 03a). Aanbevolen bij
# libxfce4ui/libwnck/xfwm4/xfdesktop.
set -euo pipefail
cd /sources
tar -xf startup-notification-0.12.tar.gz
cd startup-notification-0.12

./configure --prefix=/usr --disable-static
make
make install
install -v -m644 -D doc/startup-notification.txt \
    /usr/share/doc/startup-notification-0.12/startup-notification.txt

cd /sources
rm -rf startup-notification-0.12
echo "==> startup-notification klaar"
