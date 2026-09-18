#!/bin/bash
# Draait als root. LFS-boek hoofdstuk 4.2 (directory layout) + 4.3
# (lfs-gebruiker aanmaken). Faithfully vertaald naar een containeromgeving:
# $LFS is hier een gewone map (geen apart partitie/mount nodig).
set -euo pipefail

export LFS=/mnt/lfs

echo "==> Directory layout aanmaken onder \$LFS ($LFS)"
mkdir -pv "$LFS"/{etc,var} "$LFS"/usr/{bin,lib,sbin}
for i in bin lib sbin; do
  ln -sfv usr/$i "$LFS/$i"
done
case $(uname -m) in
  x86_64) mkdir -pv "$LFS/lib64" ;;
esac
mkdir -pv "$LFS/tools"
mkdir -pv "$LFS/sources"
chmod -v a+wt "$LFS/sources"

echo "==> lfs-gebruiker aanmaken"
if ! getent group lfs >/dev/null; then
  groupadd lfs
fi
if ! id -u lfs >/dev/null 2>&1; then
  useradd -s /bin/bash -g lfs -m -k /dev/null lfs
fi

echo "==> Eigenaarschap zetten"
chown -Rv lfs "$LFS"/{usr{,/*},var,etc,tools,sources}
case $(uname -m) in
  x86_64) chown -v lfs "$LFS/lib64" ;;
esac

echo "==> Host-voorbereiding klaar"
