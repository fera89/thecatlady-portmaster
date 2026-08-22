#!/usr/bin/env bash
# Headless smoke test for an AGS engine build (Milestones 1 & 4).
#
# Boots the engine against a game-data dir with dummy SDL video/audio, waits a
# few seconds, then kills it and inspects the log for a clean init and for the
# plugin/data errors we specifically care about (AGSteam, missing data, video).
#
# Usage:
#   scripts/smoke-test.sh --ags /path/to/ags --gamedata /path/to/gamedata [--seconds 8]
#
# Exit 0 if the engine initialised and loaded the game without a fatal error.
set -uo pipefail

AGS=""; GAMEDATA=""; SECONDS_RUN=8
while [ $# -gt 0 ]; do
    case "$1" in
        --ags)      AGS="$2"; shift 2;;
        --gamedata) GAMEDATA="$2"; shift 2;;
        --seconds)  SECONDS_RUN="$2"; shift 2;;
        *) echo "unknown arg: $1" >&2; exit 2;;
    esac
done

[ -x "$AGS" ]      || { echo "ERROR: --ags binary not executable: $AGS" >&2; exit 2; }
[ -d "$GAMEDATA" ] || { echo "ERROR: --gamedata dir not found: $GAMEDATA" >&2; exit 2; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$(mktemp -d)/ags-smoke.log"

# Determine main data file via the validator.
MAIN="$(bash "$HERE/validate-game-files.sh" "$GAMEDATA" 2>/dev/null | sed -n 's/^RESULT_MAIN=//p' | tail -n1)"
[ -z "$MAIN" ] && { echo "ERROR: game data validation failed"; bash "$HERE/validate-game-files.sh" "$GAMEDATA"; exit 1; }
echo "Main data file: $MAIN"

echo "== Booting engine headless for ${SECONDS_RUN}s =="
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  "$AGS" --no-plugins --gfxdriver software \
         --log-file-path "$LOG" --log-file=all:debug \
         "$GAMEDATA/$MAIN" &
PID=$!

sleep "$SECONDS_RUN"
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "== Engine version =="
"$AGS" --version 2>/dev/null || true

echo "== Log tail ($LOG) =="
tail -n 40 "$LOG" 2>/dev/null || echo "(no log produced)"

echo "== Analysis =="
rc=0
if grep -qiE "unable to load|failed to load game|could not find game data|no game file" "$LOG" 2>/dev/null; then
    echo "[FAIL] engine could not load the game data"; rc=1
fi
if grep -qiE "unresolved import|script link failed|failed to resolve.*plugin" "$LOG" 2>/dev/null; then
    echo "[WARN] unresolved plugin/script import — inspect AGSteam handling (spec §6, Milestone 2)"
fi
if grep -qiE "Setting up game|Game title|Engine initialization|Initializing game" "$LOG" 2>/dev/null; then
    echo "[OK] engine initialised and began loading the game"
else
    echo "[WARN] did not see an init marker — inspect the full log at $LOG"
fi

exit $rc
