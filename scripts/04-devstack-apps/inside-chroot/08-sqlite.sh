#!/bin/bash
# BLFS 12.4 — SQLite-3.50.4. Draait binnen chroot, als root. Geen
# dependencies buiten wat al aanwezig is. Letterlijk het boek se
# eigen configure-aanroep (niet zelf verzonnen CPPFLAGS).
#
# BOEK-OPMERKING (belangrijk, direct opgevolgd): "Several packages use
# an sqlite Python plugin. After installing this package, Python-
# 3.13.7 should be rebuilt to create this plugin." — Python (hoofdstuk
# 8) werd gebouwd VOORDAT SQLite bestond, dus zonder het ingebouwde
# `sqlite3`-modules. Hier meteen na SQLite zelf herbouwd — zie
# 09-python-rebuild-sqlite3.sh.
set -euo pipefail
cd /sources
tar -xf sqlite-autoconf-3500400.tar.gz
cd sqlite-autoconf-3500400

./configure --prefix=/usr     \
    --disable-static  \
    --enable-fts{4,5} \
    CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
              -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
              -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
              -D SQLITE_SECURE_DELETE=1"
make
make install

cd /sources
rm -rf sqlite-autoconf-3500400
echo "==> SQLite klaar: $(sqlite3 --version)"
