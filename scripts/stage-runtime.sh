#!/usr/bin/env bash
# Stage the built ARM engine + support files into the PortMaster port layout
# (spec §8, §36 Step 7). Does NOT touch proprietary game data.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=./versions.env
source "$HERE/versions.env"

BUILD="$ROOT/build/ags-aarch64"
PORT="$ROOT/port/thecatlady"
INNER="$PORT/thecatlady"

mkdir -p "$INNER"/{bin,lib,config,licenses,logs,saves,gamedata}

# --- engine binary ---------------------------------------------------------
BIN="$(find "$BUILD" -type f -name ags -perm -u+x 2>/dev/null | head -n1 || true)"
if [ -z "$BIN" ]; then
    echo "ERROR: built ags not found under $BUILD. Run build-ags-aarch64.sh first." >&2
    exit 1
fi
install -m 0755 "$BIN" "$INNER/bin/ags"
# strip to shrink (ignore failure if cross-strip missing)
"${CROSS_TRIPLE:-aarch64-linux-gnu}-strip" "$INNER/bin/ags" 2>/dev/null || true
echo "[OK] staged engine -> $INNER/bin/ags"

# --- shared libraries the engine needs (if not fully static) ---------------
# Copy any arm .so produced alongside the build. If the engine was linked
# statically, this list may legitimately be empty.
copied_libs=0
while IFS= read -r -d '' so; do
    install -m 0644 "$so" "$INNER/lib/"
    copied_libs=$((copied_libs+1))
done < <(find "$BUILD" -type f -name '*.so*' -print0 2>/dev/null)
echo "[OK] staged $copied_libs shared library file(s) -> $INNER/lib/"
[ "$copied_libs" -eq 0 ] && echo "     (none found — engine is likely statically linked; verify with ldd on device)"

# --- validator, config, controls ------------------------------------------
install -m 0755 "$HERE/validate-game-files.sh" "$INNER/bin/validate-game-files"
install -m 0644 "$ROOT/runtime/config/acsetup-r36s.cfg" "$INNER/config/acsetup.cfg"
# gptk + asoundrc live inside GAMEDIR (the inner thecatlady/ dir), which the
# launcher references as $GAMEDIR/thecatlady.gptk and $GAMEDIR/asoundrc.
install -m 0644 "$ROOT/runtime/controls/thecatlady.gptk" "$INNER/thecatlady.gptk"
install -m 0644 "$ROOT/runtime/config/asoundrc" "$INNER/asoundrc"
echo "[OK] staged validator, acsetup.cfg, thecatlady.gptk, asoundrc"

# --- licenses (spec §25) ---------------------------------------------------
if [ -f "$ROOT/LICENSES.md" ]; then
    install -m 0644 "$ROOT/LICENSES.md" "$INNER/licenses/LICENSES.md"
fi
# Copy the upstream AGS license if the source is present.
for l in "$ROOT/upstream/ags/License.txt" "$ROOT/upstream/ags/LICENSE" "$ROOT/upstream/ags/Copyright.txt"; do
    [ -f "$l" ] && install -m 0644 "$l" "$INNER/licenses/AGS-$(basename "$l")"
done
echo "[OK] staged licenses -> $INNER/licenses/"

# --- record the staged engine version for logs ----------------------------
echo "$AGS_VERSION ($AGS_GIT_TAG @ $AGS_GIT_COMMIT)" > "$INNER/bin/AGS_VERSION.txt"

echo
echo "Staged runtime is in: $PORT"
echo "Run the architecture audit next: ./scripts/audit-arch.sh"
