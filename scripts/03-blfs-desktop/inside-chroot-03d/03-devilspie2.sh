#!/bin/bash
# devilspie2-0.36. Draait binnen chroot, als root. Niet in BLFS —
# officiële GitHub-tag van de hoofdontwikkelaar (gusnan/devilspie2).
# Vereist (uit het eigen Makefile, pkg-config-namen letterlijk
# nagekeken): gtk+-3.0 (03b), libwnck-3.0 (03c, geleverd door
# libwnck-43.2), lua (deze fase, 01-lua.sh), libX11 (03a). Eigen
# Makefile gebruikt PREFIX i.p.v. een configure-script.
set -euo pipefail
cd /sources
tar -xf devilspie2-0.36.tar.gz
cd devilspie2-0.36

make PREFIX=/usr
make PREFIX=/usr install

cd /sources
rm -rf devilspie2-0.36
echo "==> devilspie2 klaar"
