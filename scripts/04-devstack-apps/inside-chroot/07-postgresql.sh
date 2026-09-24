#!/bin/bash
# BLFS 12.4 — PostgreSQL-17.6. Draait binnen chroot, als root. Geen
# harde Required-dependencies (alle BLFS-vermelde deps zijn Optional —
# OpenSSL/Perl/Python al aanwezig sinds hoofdstuk 8, --with-tcl bewust
# niet gebruikt, geen Tcl gebouwd).
# '--without-icu' — PostgreSQL 17's configure detecteert/vereist ICU
# standaard AAN (echte fout: "checking whether to build with ICU
# support... yes" -> "ICU library not found"), ook al noemt het
# boek-voorbeeld deze vlag niet expliciet. ICU bewust niet gebouwd
# (groot pakket, alleen "Optional" voor PostgreSQL) — zelfde fix als de
# foutmelding zelf voorstelt.
#
# BEWUSTE GRENS: alleen de server-/client-programma's + de postgres-
# systeemgebruiker/groep worden hier aangemaakt. `initdb` (het
# daadwerkelijk aanmaken van een database-cluster op schijf) draait
# hier NIET — dat hoort bij de first-boot-wizard (elke installatie
# moet zijn EIGEN, verse database krijgen, geen gedeelde data in een
# generiek image; zelfde architectuur-scheiding als BLUEPRINT.md al
# vastlegt voor hoofdstuk-9-systeemconfiguratie).
set -euo pipefail
cd /sources
tar -xf postgresql-17.6.tar.bz2
cd postgresql-17.6

sed -i '/DEFAULT_PGSOCKET_DIR/s@/tmp@/run/postgresql@' src/include/pg_config_manual.h

./configure --prefix=/usr \
    --docdir=/usr/share/doc/postgresql-17.6 \
    --without-icu
make
make install

groupadd -g 41 postgres
useradd -c "PostgreSQL Server" -g postgres -d /srv/pgsql/data \
    -u 41 postgres

cd /sources
rm -rf postgresql-17.6
echo "==> PostgreSQL klaar (initdb volgt in de first-boot-wizard): $(psql --version)"
