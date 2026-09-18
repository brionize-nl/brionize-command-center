# Gedeelde build-omgeving voor fase 1 (LFS 12.4, hoofdstuk 4 & 5).
# Wordt gesourced door elk 0X-*.sh script — geen afhankelijkheid van
# .bash_profile/.bashrc login-chains, want scripts draaien non-interactief
# via 'su lfs -c'.
set -euo pipefail

export LFS=/mnt/lfs
export LC_ALL=POSIX
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
export PATH=$LFS/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS="-j$(nproc)"
