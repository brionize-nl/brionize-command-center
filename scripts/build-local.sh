#!/usr/bin/env bash
# Bouwt de wegwerp-Docker-sandbox en draait fase 1 (toolchain) erin.
# Zelfde pad werkt straks ook in GitHub Actions — dit script is de
# lokale-fallback-entrypoint op Brionize's eigen machine (zie BLUEPRINT.md).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_TAG="brionize-lfs-toolchain:latest"
LFS_DIR="$REPO_ROOT/build/lfs"

mkdir -p "$LFS_DIR"

echo "==> Docker-image bouwen ($IMAGE_TAG)"
docker build -t "$IMAGE_TAG" -f "$REPO_ROOT/docker/Dockerfile.build" "$REPO_ROOT"

echo "==> Fase 1 (toolchain) draaien in container"
docker run --rm \
  -v "$LFS_DIR:/mnt/lfs" \
  -v "$REPO_ROOT/scripts/01-toolchain:/opt/lfs/scripts:ro" \
  "$IMAGE_TAG" \
  bash /opt/lfs/scripts/run-all.sh
