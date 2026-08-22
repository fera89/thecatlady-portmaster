#!/usr/bin/env bash
# One-shot ARM engine build using Docker (no local Linux toolchain needed).
#
# Produces a genuine aarch64 engine + bundled libs and stages them into the
# PortMaster port layout. Requires Docker with buildx + QEMU/binfmt (Docker
# Desktop has this out of the box). See docs/BUILD.md.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=./versions.env
source "$HERE/versions.env"

command -v docker >/dev/null || { echo "ERROR: docker not found. Install Docker Desktop." >&2; exit 1; }

OUT="$ROOT/build/arm64-out"
rm -rf "$OUT"; mkdir -p "$OUT"

echo "== Building AGS $AGS_VERSION for linux/arm64 via Docker buildx =="
# Ensure emulation is registered (no-op if already set up).
docker run --rm --privileged tonistiigi/binfmt --install arm64 >/dev/null 2>&1 || true

docker buildx build \
    --platform linux/arm64 \
    --build-arg "AGS_REPO=$AGS_REPO" \
    --build-arg "AGS_GIT_COMMIT=$AGS_GIT_COMMIT" \
    --target export \
    --output "type=local,dest=$OUT" \
    -f "$ROOT/docker/Dockerfile" \
    "$ROOT"

# Feed the existing staging script (it looks under build/ags-aarch64/).
mkdir -p "$ROOT/build/ags-aarch64/bundled-lib"
cp "$OUT/bin/ags" "$ROOT/build/ags-aarch64/ags"
chmod +x "$ROOT/build/ags-aarch64/ags"
if [ -d "$OUT/lib" ]; then cp -a "$OUT/lib/." "$ROOT/build/ags-aarch64/bundled-lib/" 2>/dev/null || true; fi

echo "== Staging runtime =="
"$HERE/stage-runtime.sh"

echo "== Architecture audit =="
"$HERE/audit-arch.sh"

echo
echo "[OK] Docker build complete. Engine + libs staged into port/thecatlady/thecatlady/"
echo "Next: copy your game data into gamedata/, then ./scripts/make-portmaster-package.sh"
