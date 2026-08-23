#!/bin/bash
# ===========================================================================
# The Cat Lady — PortMaster launcher for R36S / ArkOS (spec §20)
# Native AArch64 Adventure Game Studio runtime. No x86 emulation.
# Structure follows the current PortMaster port convention (verified against
# working ArkOS R36S ports: undertale.sh / render96ex.sh).
# ===========================================================================

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

# --- locate PortMaster control folder (standard detection chain) -----------
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# --- paths -----------------------------------------------------------------
GAMEDIR="/$directory/ports/thecatlady"
cd "$GAMEDIR" || exit 1

mkdir -p "$GAMEDIR/saves" "$GAMEDIR/logs" "$GAMEDIR/config"

# tee all output to a log (spec §18)
> "$GAMEDIR/logs/launcher.log" && exec > >(tee "$GAMEDIR/logs/launcher.log") 2>&1

echo "===== The Cat Lady launch: $(date '+%Y-%m-%d %H:%M:%S') ====="
echo "CFW: ${CFW_NAME:-?}  device: ${DEVICE_NAME:-?}  arch: ${DEVICE_ARCH:-?}  ${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?}"
echo "uname: $(uname -a)"

# --- environment -----------------------------------------------------------
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
# Redirect all AGS save/config writes into the port dir (spec §17, clean uninstall)
export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"

$ESUDO chmod +x "$GAMEDIR/bin/ags" 2>/dev/null
$ESUDO chmod +x "$GAMEDIR/bin/validate-game-files" 2>/dev/null
[ -x "$GAMEDIR/bin/ags" ] || { echo "ERROR: $GAMEDIR/bin/ags missing/not executable"; exit 1; }
echo "AGS engine: $("$GAMEDIR/bin/ags" --version 2>/dev/null | tail -1)"

# --- ArkOS ALSA dmix fix (matches working R36S ports) ----------------------
# ArkOS removes ~/.asoundrc before a port runs and restores it afterwards.
if [[ "$CFW_NAME" == *"ArkOS"* ]] && [ -f "$GAMEDIR/asoundrc" ]; then
  cp "$GAMEDIR/asoundrc" "$HOME/.asoundrc"
fi

# --- validate the user's game data (spec §10) ------------------------------
VALOUT="$(bash "$GAMEDIR/bin/validate-game-files" "$GAMEDIR/gamedata" 2>&1)"
VALRC=$?
echo "$VALOUT"
if [ "$VALRC" -ne 0 ]; then
  if command -v pm_message >/dev/null 2>&1; then
    pm_message "The Cat Lady game files are missing. Copy TheCatLady.ags (or .exe) + audio.vox + speech.vox into $GAMEDIR/gamedata/ . See README."
  fi
  echo "Game data validation failed."
  sleep 5
  exit 1
fi
MAIN="$(printf '%s\n' "$VALOUT" | sed -n 's/^RESULT_MAIN=//p' | tail -n1)"
[ -z "$MAIN" ] && MAIN="TheCatLady.exe"
echo "main data file: $MAIN"

# --- controls: gamepad -> mouse/keyboard (spec §19) ------------------------
$GPTOKEYB "ags" -c "$GAMEDIR/thecatlady.gptk" &
pm_platform_helper "$GAMEDIR/bin/ags"

# --- launch (spec §6 no x86 plugin, §16 --conf keeps Steam cfg untouched) ---
"$GAMEDIR/bin/ags" \
    --no-plugins \
    --fullscreen \
    --gfxdriver software \
    --conf "$GAMEDIR/config/acsetup.cfg" \
    --log-file-path "$GAMEDIR/logs/ags.log" \
    --log-file=all:info \
    "$GAMEDIR/gamedata/$MAIN"

# --- restore controller/display state, return to frontend (spec §20) -------
pm_finish
