#!/bin/bash
# LFS 12.4 hoofdstuk 8.85 — Cleaning Up. Draait binnen chroot, als root.
set -euo pipefail
cd /sources

rm -rf /tmp/{*,.*}

find /usr/lib /usr/libexec -name \*.la -delete

find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

userdel -r tester

cd /sources
echo "==> Cleaning Up klaar"
