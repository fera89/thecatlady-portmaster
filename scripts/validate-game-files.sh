#!/usr/bin/env bash
# Validate that the user has copied their legitimate The Cat Lady game data
# (spec §10). Runs on the R36S at launch and on the desktop during Milestone 1.
#
# Accepts EITHER game-data layout, because AGS game data is platform-independent:
#   * Linux depot : TheCatLady.ags  (+ optional TheCatLady.001/.002 splits)
#   * Windows/Steam: TheCatLady.exe (+ TheCatLady.001/.002 splits)   <-- what most
#                    users already have installed.
#
# Requires: main data file + audio.vox + speech.vox.
# Detects (optional): *.tra translations (Portuguese.tra highlighted).
#
# On success the LAST stdout line is:   RESULT_MAIN=<basename-of-main-data-file>
# so the launcher can learn which file to hand to the engine.
#
# Usage: validate-game-files.sh [GAMEDATA_DIR]
set -euo pipefail

GAMEDATA="${1:-}"
if [ -z "$GAMEDATA" ]; then
    HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Default to the staged port layout: <port>/thecatlady/gamedata
    GAMEDATA="$(cd "$HERE/.." && pwd)/port/thecatlady/thecatlady/gamedata"
fi

say()  { printf '%s\n' "$*"; }
fail() { printf '%s\n' "$*" >&2; }

if [ ! -d "$GAMEDATA" ]; then
    fail "ERROR: game-data directory not found: $GAMEDATA"
    exit 1
fi

# --- locate the main AGS data file ----------------------------------------
MAIN=""
if   [ -f "$GAMEDATA/TheCatLady.ags" ]; then MAIN="TheCatLady.ags"
elif [ -f "$GAMEDATA/TheCatLady.exe" ]; then MAIN="TheCatLady.exe"
elif [ -f "$GAMEDATA/ac2game.dat"    ]; then MAIN="ac2game.dat"
fi

nonzero() { [ -f "$1" ] && [ "$(stat -c%s "$1" 2>/dev/null || echo 0)" -gt 0 ]; }

ok=1

if [ -n "$MAIN" ] && nonzero "$GAMEDATA/$MAIN"; then
    say "[OK] main game data found: $MAIN"
else
    say "[--] main game data MISSING (need TheCatLady.ags or TheCatLady.exe)"
    ok=0
fi

for f in audio.vox speech.vox; do
    if nonzero "$GAMEDATA/$f"; then
        say "[OK] $f found"
    else
        say "[--] $f MISSING"
        ok=0
    fi
done

# split archives are optional but note them if the main file is small
for s in TheCatLady.001 TheCatLady.002 TheCatLady.003; do
    [ -f "$GAMEDATA/$s" ] && say "[OK] split archive present: $s"
done

# translations (optional). Portuguese highlighted per acceptance criteria.
tra_count=0
shopt -s nullglob
for t in "$GAMEDATA"/*.tra; do
    tra_count=$((tra_count+1))
done
shopt -u nullglob
if [ -f "$GAMEDATA/Portuguese.tra" ]; then
    say "[OK] Portuguese.tra found"
fi
say "[i]  translations detected: $tra_count *.tra file(s)"

if [ "$ok" -ne 1 ]; then
    fail ""
    fail "The Cat Lady game data was not found (or is incomplete)."
    fail ""
    fail "This port requires the game files from an ORIGINAL copy you own."
    fail "Copy them into:"
    fail "    $GAMEDATA"
    fail ""
    fail "Required:"
    fail "  - TheCatLady.ags   (Linux depot)  OR  TheCatLady.exe (Windows/Steam)"
    fail "  - audio.vox"
    fail "  - speech.vox"
    fail "Also copy any TheCatLady.00N split files and the *.tra you want."
    fail ""
    fail "Do NOT copy ags32 / ags64 / lib32 / lib64 — they are not used."
    exit 1
fi

# Optional SHA-256 for debugging (never required for launch, spec §10).
if [ "${PRINT_SHA:-0}" = "1" ] && command -v sha256sum >/dev/null; then
    say "-- sha256 (debug) --"
    ( cd "$GAMEDATA" && sha256sum "$MAIN" audio.vox speech.vox 2>/dev/null || true )
fi

say ""
say "Game data detected. Main data file: $MAIN"
# Machine-readable result (must be the final stdout line):
say "RESULT_MAIN=$MAIN"
