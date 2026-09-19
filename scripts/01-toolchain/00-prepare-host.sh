#!/bin/bash
# Draait als root. LFS-boek hoofdstuk 4.2 (directory layout). De
# lfs-gebruiker (4.3) staat inmiddels al in docker/Dockerfile.build gebakken
# (niet meer hier aangemaakt) — nodig zodra een build in twee losse
# 'docker run'-aanroepen wordt opgesplitst (bootstrap-cache-checkpoint vs.
# hoofdstuk 8), zodat elke container 'm meteen heeft.
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

echo "==> Eigenaarschap zetten"
chown -Rv lfs "$LFS"/{usr{,/*},var,etc,tools,sources}
case $(uname -m) in
  x86_64) chown -v lfs "$LFS/lib64" ;;
esac

echo "==> Host-voorbereiding klaar"
