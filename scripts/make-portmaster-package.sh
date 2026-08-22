#!/usr/bin/env bash
# Build the installable PortMaster zip (spec §24, §36). Runs the architecture
# audit first and refuses to package if any proprietary game data leaked in.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PORT="$ROOT/port/thecatlady"
INNER="$PORT/thecatlady"
DIST="$ROOT/dist"

# --- guard 1: engine must be staged ---------------------------------------
[ -x "$INNER/bin/ags" ] || { echo "ERROR: staged engine missing. Run stage-runtime.sh." >&2; exit 1; }

# --- guard 2: no proprietary game data may be packaged (spec §4, §32) ------
echo "== Checking for forbidden proprietary files =="
FORBIDDEN='TheCatLady.ags|TheCatLady.exe|TheCatLady\.[0-9]{3}|audio\.vox|speech\.vox|\.tra$|libagsteam\.so|agsteam\.dll|steam_api'
leak="$(find "$PORT" -type f | grep -EI "$FORBIDDEN" || true)"
if [ -n "$leak" ]; then
    echo "REFUSING TO PACKAGE — proprietary/forbidden files present:" >&2
    echo "$leak" >&2
    exit 1
fi
echo "[OK] no proprietary game data in package tree"

# --- guard 3: architecture audit (spec §14) -------------------------------
echo "== Architecture audit =="
"$HERE/audit-arch.sh"

# --- guard 4: licenses present (spec §25) ---------------------------------
if ! ls "$INNER/licenses/"* >/dev/null 2>&1; then
    echo "WARNING: no license files staged in $INNER/licenses/ (spec §25)" >&2
fi

# --- build the zip ---------------------------------------------------------
mkdir -p "$DIST"
STAMP="$(date +%Y%m%d)"
ZIP="$DIST/thecatlady-r36s-${STAMP}.zip"
rm -f "$ZIP"

# PortMaster expects the launcher .sh and the inner game dir at the zip root.
( cd "$PORT" && zip -r -y "$ZIP" \
    "The Cat Lady.sh" \
    "thecatlady" \
    "port.json" \
    "gameinfo.xml" \
    "README.md" \
    "screenshot.png" \
    "cover.png" \
    -x "thecatlady/gamedata/*" \
    -x "thecatlady/saves/*" \
    -x "thecatlady/logs/*" \
    2>/dev/null || \
  cd "$PORT" && zip -r -y "$ZIP" "The Cat Lady.sh" "thecatlady" "port.json" "gameinfo.xml" "README.md" \
    -x "thecatlady/gamedata/*" -x "thecatlady/saves/*" -x "thecatlady/logs/*" )

# Keep the gamedata placeholder in the zip so the target folder exists.
( cd "$PORT" && zip "$ZIP" "thecatlady/gamedata/PUT_STEAM_LINUX_FILES_HERE.txt" >/dev/null )

echo
echo "[OK] package built: $ZIP"
echo "Size: $(du -h "$ZIP" | cut -f1)"
echo "Contents:"
unzip -l "$ZIP" | sed 's/^/    /'
