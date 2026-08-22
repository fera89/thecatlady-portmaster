#!/usr/bin/env bash
# Cross-compile the AGS engine for AArch64 Linux (spec §11, §12).
#
# Requires an AArch64 toolchain + target dev libraries. The supported/tested
# way to get these is the Docker builder (scripts/docker-build.sh), which uses
# a Debian arm64 sysroot. You can also run this directly on an x86_64 Linux /
# WSL2 host that has:
#     aarch64-linux-gnu-gcc/g++, cmake, ninja
#     arm64 dev packages for SDL2, ogg, vorbis, theora (in a sysroot)
#
# Keeps video ENABLED (spec §7). Uses portable -march=armv8-a (spec §11).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=./versions.env
source "$HERE/versions.env"

SRC="$ROOT/upstream/ags"
BUILD="$ROOT/build/ags-aarch64"
TOOLCHAIN="$ROOT/toolchains/aarch64-linux-gnu.cmake"

if [ ! -d "$SRC" ]; then
    echo "ERROR: $SRC missing. Run scripts/fetch-ags.sh first." >&2
    exit 1
fi

command -v cmake >/dev/null || { echo "ERROR: cmake not found" >&2; exit 1; }

# Prefer Ninja if available.
GEN=(); command -v ninja >/dev/null && GEN=(-G Ninja)

echo "== Configuring AGS $AGS_VERSION for aarch64 =="
cmake "${GEN[@]}" \
    -S "$SRC" \
    -B "$BUILD" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
    -DAGS_BUILD_ENGINE=ON \
    -DAGS_BUILD_TOOLS=OFF \
    -DAGS_BUILD_COMPILER=OFF \
    -DAGS_TESTS=OFF \
    "${EXTRA_CMAKE_ARGS:-}"
    # NOTE: AGS_NO_VIDEO_PLAYER is intentionally left OFF (video stays enabled, spec §7).

echo "== Building =="
cmake --build "$BUILD" --config Release -j"$(nproc 2>/dev/null || echo 4)"

# Locate the produced engine binary (name/location can vary by release).
BIN="$(find "$BUILD" -type f -name ags -perm -u+x 2>/dev/null | head -n1 || true)"
[ -z "$BIN" ] && BIN="$(find "$BUILD" -type f -name 'ags*' -perm -u+x 2>/dev/null | grep -viE '\.(so|a|cmake|o)$' | head -n1 || true)"

if [ -z "$BIN" ]; then
    echo "ERROR: could not find built ags binary under $BUILD" >&2
    exit 1
fi

echo "[OK] Built: $BIN"
echo "-- architecture check --"
file "$BIN" || true
"$HERE/audit-arch.sh" "$BIN"

echo
echo "Next: ./scripts/stage-runtime.sh"
