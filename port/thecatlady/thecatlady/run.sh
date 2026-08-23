#!/bin/bash
# ===========================================================================
# Shared runner for The Cat Lady R36S launchers. Each launcher wrapper sets a
# few TCL_* env vars and sources this file, so we can A/B test video profiles
# with separate logs.  (spec §20)
#
#   TCL_TAG              label used for the log filenames (e.g. kmsdrm-sw)
#   TCL_SDL_VIDEODRIVER  force SDL video driver; empty = let SDL auto-detect
#   TCL_GFXDRIVER        AGS renderer: software | ogl   (default: software)
# ===========================================================================

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if   [ -d "/opt/system/Tools/PortMaster/" ]; then controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ];       then controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ];    then controlfolder="$XDG_DATA_HOME/PortMaster"
else controlfolder="/roms/ports/PortMaster"; fi
source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/thecatlady"
cd "$GAMEDIR" || exit 1
mkdir -p "$GAMEDIR/saves" "$GAMEDIR/logs" "$GAMEDIR/config"

TAG="${TCL_TAG:-default}"
GFX="${TCL_GFXDRIVER:-software}"
LOG="$GAMEDIR/logs/run-$TAG.log"
: > "$LOG" && exec > >(tee "$LOG") 2>&1

echo "===== The Cat Lady [$TAG]  $(date '+%F %T') ====="
echo "profile: SDL_VIDEODRIVER='${TCL_SDL_VIDEODRIVER:-(auto)}'   AGS gfxdriver=$GFX"
echo "CFW=$CFW_NAME  device=${DEVICE_NAME:-?}  arch=${DEVICE_ARCH:-?}  ${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?}"
echo "uname: $(uname -a)"

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"
if [ -n "${TCL_SDL_VIDEODRIVER:-}" ]; then export SDL_VIDEODRIVER="$TCL_SDL_VIDEODRIVER"; else unset SDL_VIDEODRIVER; fi

$ESUDO chmod +x "$GAMEDIR/bin/ags" "$GAMEDIR/bin/validate-game-files" 2>/dev/null
echo "engine: $("$GAMEDIR/bin/ags" --version 2>/dev/null | tail -1)"
printf 'SDL video drivers compiled in: '; strings "$GAMEDIR/bin/ags" 2>/dev/null | grep -ixE 'kmsdrm|x11|wayland|offscreen|dummy' | sort -u | tr '\n' ' '; echo
echo "/dev/dri:"; ls -l /dev/dri 2>/dev/null || echo "  (none)"

# ArkOS ALSA dmix fix
[[ "$CFW_NAME" == *"ArkOS"* ]] && [ -f "$GAMEDIR/asoundrc" ] && cp "$GAMEDIR/asoundrc" "$HOME/.asoundrc"

# validate game data
VAL="$(bash "$GAMEDIR/bin/validate-game-files" "$GAMEDIR/gamedata" 2>&1)"; echo "$VAL"
MAIN="$(printf '%s\n' "$VAL" | sed -n 's/^RESULT_MAIN=//p' | tail -n1)"; [ -z "$MAIN" ] && MAIN="TheCatLady.exe"

# controls
$GPTOKEYB "ags" -c "$GAMEDIR/thecatlady.gptk" &
pm_platform_helper "$GAMEDIR/bin/ags" 2>/dev/null

echo "----- launching ags (gfx=$GFX) -----"
"$GAMEDIR/bin/ags" \
    --no-plugins --fullscreen --gfxdriver "$GFX" \
    --conf "$GAMEDIR/config/acsetup.cfg" \
    --log-file-path "$GAMEDIR/logs/ags-$TAG.log" --log-file=all:all \
    "$GAMEDIR/gamedata/$MAIN"
echo "----- ags exited: $? -----"

pm_finish
