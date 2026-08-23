#!/bin/bash
# ===========================================================================
# Shared runner for The Cat Lady R36S launchers. Each launcher wrapper sets a
# few TCL_* env vars and sources this file, so we can A/B test video profiles
# with separate logs.  (spec §19, §20)
#
#   TCL_TAG              label used for the log filenames (e.g. gl4es-ogl)
#   TCL_GFXDRIVER        AGS renderer: software | ogl        (default software)
#   TCL_GL4ES            1 = route GL through bundled GL4ES (gl4es.aarch64/)
#   TCL_SDL_VIDEODRIVER  force SDL video driver; empty = auto-detect
#   TCL_LIBGL_FB         override GL4ES LIBGL_FB (e.g. 2, 3, 4)
#
# Why GL4ES: on this RK3326/Mali + old kernel, SDL's native KMSDRM cannot make
# GBM/EGL surfaces ("Can't window GBM/EGL surfaces"), so nothing displays. The
# working ports here (Penumbra, Perfect Dark) render through GL4ES, which builds
# a Mali-compatible EGL context on the framebuffer. We mirror that.
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
echo "CFW=$CFW_NAME device=${DEVICE_NAME:-?} arch=${DEVICE_ARCH:-?} ${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?}"
echo "uname: $(uname -a)"

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"

# --- GL4ES path (mirrors the working ports on this device) -----------------
if [ "${TCL_GL4ES:-0}" = "1" ]; then
  GFX="ogl"
  if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then
    source "${controlfolder}/libgl_${CFW_NAME}.txt"
  else
    source "${controlfolder}/libgl_default.txt"
  fi
  # Point SDL's GL/EGL at our bundled aarch64 GL4ES.
  export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
  export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
  [ -n "${TCL_LIBGL_FB:-}" ] && export LIBGL_FB="$TCL_LIBGL_FB"
  export LIBGL_NOERROR=1
fi

if [ -n "${TCL_SDL_VIDEODRIVER:-}" ]; then export SDL_VIDEODRIVER="$TCL_SDL_VIDEODRIVER"; else unset SDL_VIDEODRIVER; fi

echo "profile: gl4es=${TCL_GL4ES:-0}  AGS gfx=$GFX  SDL_VIDEODRIVER='${SDL_VIDEODRIVER:-(auto)}'"
echo "LIBGL: ES=${LIBGL_ES:-} GL=${LIBGL_GL:-} FB=${LIBGL_FB:-}  SDL_VIDEO_GL_DRIVER=${SDL_VIDEO_GL_DRIVER:-}"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "/dev/dri:"; ls -l /dev/dri 2>/dev/null || echo "  (none)"

$ESUDO chmod +x "$GAMEDIR/bin/ags" "$GAMEDIR/bin/validate-game-files" 2>/dev/null
echo "engine: $("$GAMEDIR/bin/ags" --version 2>/dev/null | tail -1)"

# ArkOS ALSA dmix fix
[[ "$CFW_NAME" == *"ArkOS"* ]] && [ -f "$GAMEDIR/asoundrc" ] && cp "$GAMEDIR/asoundrc" "$HOME/.asoundrc"

VAL="$(bash "$GAMEDIR/bin/validate-game-files" "$GAMEDIR/gamedata" 2>&1)"; echo "$VAL"
MAIN="$(printf '%s\n' "$VAL" | sed -n 's/^RESULT_MAIN=//p' | tail -n1)"; [ -z "$MAIN" ] && MAIN="TheCatLady.exe"

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
