#!/bin/bash
# ===========================================================================
# The Cat Lady — PortMaster launcher for R36S / ArkOS (spec §20)
# Native AArch64 Adventure Game Studio runtime. No x86 emulation.
# ===========================================================================
set -u

# --- PortMaster control environment (current convention) -------------------
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

controlfolder="/opt/system/Tools/PortMaster"
[ -f "/opt/tools/PortMaster/control.txt" ]   && controlfolder="/opt/tools/PortMaster"
[ -f "/roms/ports/PortMaster/control.txt" ]  && controlfolder="/roms/ports/PortMaster"
source "$controlfolder/control.txt"

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# --- paths -----------------------------------------------------------------
GAMEDIR="/$directory/ports/thecatlady"
cd "$GAMEDIR" || { echo "Cannot cd to $GAMEDIR"; exit 1; }

mkdir -p "$GAMEDIR/saves" "$GAMEDIR/logs" "$GAMEDIR/config"

# --- logging (spec §18): tee everything to launcher.log --------------------
LOG="$GAMEDIR/logs/launcher.log"
: > "$LOG"
exec > >(tee "$LOG") 2>&1

echo "===== The Cat Lady launch: $(date '+%Y-%m-%d %H:%M:%S') ====="
echo "uname     : $(uname -a)"
echo "arch      : $(uname -m)"
echo "GAMEDIR   : $GAMEDIR"

# --- environment (spec §16 config, §17 saves) ------------------------------
export LD_LIBRARY_PATH="$GAMEDIR/lib:${LD_LIBRARY_PATH:-}"
# Redirect all AGS save/config writes into the port dir (spec §17).
export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"
export SDL_GAMECONTROLLERCONFIG="${SDL_GAMECONTROLLERCONFIG:-}"

echo "LD_LIBRARY_PATH : $LD_LIBRARY_PATH"
echo "XDG_DATA_HOME   : $XDG_DATA_HOME"

$ESUDO chmod +x "$GAMEDIR/bin/ags" 2>/dev/null || true
[ -x "$GAMEDIR/bin/ags" ] || { echo "ERROR: $GAMEDIR/bin/ags missing or not executable"; exit 1; }

echo "AGS engine: $("$GAMEDIR/bin/ags" --version 2>/dev/null || echo '(version query failed)')"

# --- validate the user's game data (spec §10) ------------------------------
VALOUT="$(bash "$GAMEDIR/bin/validate-game-files" "$GAMEDIR/gamedata" 2>>"$GAMEDIR/logs/launcher.log")"
echo "$VALOUT"
if [ $? -ne 0 ]; then
    echo "Game data validation FAILED — see message above."
    # Show the user a message box if PortMaster provides one.
    if command -v pm_message >/dev/null 2>&1; then
        pm_message "The Cat Lady game files are missing. Copy TheCatLady.ags (or .exe), audio.vox and speech.vox into: $GAMEDIR/gamedata/"
    fi
    sleep 6
    exit 1
fi
MAIN="$(printf '%s\n' "$VALOUT" | sed -n 's/^RESULT_MAIN=//p' | tail -n1)"
[ -z "$MAIN" ] && MAIN="TheCatLady.ags"
echo "main data : $MAIN"

# --- controls: gamepad -> mouse/keyboard (spec §19) ------------------------
$GPTOKEYB "ags" -c "$GAMEDIR/thecatlady.gptk" &
GPTK_PID=$!
pm_platform_helper "$GAMEDIR/bin/ags" 2>/dev/null || true

# Ensure controller / display state is restored no matter how we exit.
cleanup() {
    kill "$GPTK_PID" 2>/dev/null || true
    $ESUDO systemctl restart oga_events 2>/dev/null || true
    if command -v pm_finish >/dev/null 2>&1; then pm_finish; fi
}
trap cleanup EXIT INT TERM

# --- launch (spec §12, §20) ------------------------------------------------
# --conf keeps the original Steam acsetup.cfg untouched (spec §16).
# --no-plugins avoids the x86 Steam plugin; AGS falls back to built-in stubs
# so gameplay continues without Steam achievements (spec §6, Strategy A).
echo "----- starting engine -----"
"$GAMEDIR/bin/ags" \
    --no-plugins \
    --fullscreen \
    --gfxdriver software \
    --conf "$GAMEDIR/config/acsetup.cfg" \
    --log-file-path "$GAMEDIR/logs/ags.log" \
    --log-file=all:info \
    "$GAMEDIR/gamedata/$MAIN"
STATUS=$?

echo "----- engine exited with status $STATUS -----"
exit $STATUS
