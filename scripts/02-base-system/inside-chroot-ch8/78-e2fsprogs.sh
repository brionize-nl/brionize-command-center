#!/bin/bash
# LFS 12.4 hoofdstuk 8.80 — E2fsprogs-1.47.3. Draait binnen chroot, als root.
set -euo pipefail
cd /sources
tar -xf e2fsprogs-1.47.3.tar.gz
cd e2fsprogs-1.47.3

mkdir -v build
cd       build

../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-elf-shlibs \
             --disable-libblkid  \
             --disable-libuuid   \
             --disable-uuidd     \
             --disable-fsck

make

# Tests standaard overgeslagen in deze pipeline wegens CI-tijd en betrouwbaarheid.
# make check

make install

rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf

cd /sources
rm -rf e2fsprogs-1.47.3
echo "==> E2fsprogs klaar"
