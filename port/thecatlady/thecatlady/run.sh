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

# The engine reads its DEFAULT config from the game-data dir (its StartupDir).
# We must NOT pass --conf: that path makes the engine read ONLY that file and
# skip the user config (engine.cpp engine_read_config early-return), which is
# where the player's language choice is persisted on exit. Instead we seed our
# tuned defaults into gamedata/acsetup.cfg each launch; the user config in
# saves/ags/<game>/acsetup.cfg is then read on top and overrides (e.g. the
# chosen translation), so the language persists across launches.
[ -f "$GAMEDIR/config/acsetup.cfg" ] && cp -f "$GAMEDIR/config/acsetup.cfg" "$GAMEDIR/gamedata/acsetup.cfg"

TAG="${TCL_TAG:-default}"
GFX="${TCL_GFXDRIVER:-software}"
AGSBIN="${TCL_AGS_BIN:-ags}"     # allow an alternate engine binary (e.g. ags-gles2)
# Log to $GAMEDIR/log.txt — the standard location PortMaster (and testers) look
# for. Everything below, including the engine's own log (via --log-stdout), is
# tee'd here so a single log.txt captures the whole run for troubleshooting.
LOG="$GAMEDIR/log.txt"
: > "$LOG" && exec > >(tee "$LOG") 2>&1

echo "===== The Cat Lady [$TAG]  $(date '+%F %T') ====="
echo "CFW=$CFW_NAME device=${DEVICE_NAME:-?} arch=${DEVICE_ARCH:-?} ${DISPLAY_WIDTH:-?}x${DISPLAY_HEIGHT:-?}"
echo "uname: $(uname -a)"

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:${LD_LIBRARY_PATH:-}"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export XDG_DATA_HOME="$GAMEDIR/saves"
export XDG_CONFIG_HOME="$GAMEDIR/saves"

# The engine links the SYSTEM libSDL2 (which drives the RK3326/Mali display).
# The device ships several SDL2 versions; force a recent one via LD_PRELOAD so
# the engine (needs >= 2.24) always resolves against a compatible SDL2.
if [ "${TCL_NO_PRELOAD:-0}" != "1" ]; then
  SYS_SDL="${TCL_SDL_PRELOAD:-$(ls -1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.* 2>/dev/null | sort -V | tail -1)}"
  [ -n "$SYS_SDL" ] && [ -e "$SYS_SDL" ] && export LD_PRELOAD="$SYS_SDL${LD_PRELOAD:+:$LD_PRELOAD}"
  echo "LD_PRELOAD SDL2: ${SYS_SDL:-<none>}"
fi

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

# Optional explicit EGL/GL driver override (e.g. force the device's Mali blob so
# SDL's window uses Mali EGL/GBM instead of mesa). Applied last, wins.
[ -n "${TCL_SDL_EGL_DRIVER:-}" ] && export SDL_VIDEO_EGL_DRIVER="$TCL_SDL_EGL_DRIVER"
[ -n "${TCL_SDL_GL_DRIVER:-}" ]  && export SDL_VIDEO_GL_DRIVER="$TCL_SDL_GL_DRIVER"

echo "profile: gl4es=${TCL_GL4ES:-0}  AGS gfx=$GFX  SDL_VIDEODRIVER='${SDL_VIDEODRIVER:-(auto)}'"
echo "LIBGL: ES=${LIBGL_ES:-} GL=${LIBGL_GL:-} FB=${LIBGL_FB:-}"
echo "SDL_VIDEO_GL_DRIVER=${SDL_VIDEO_GL_DRIVER:-}  SDL_VIDEO_EGL_DRIVER=${SDL_VIDEO_EGL_DRIVER:-}"
echo "engine NEEDED SDL: $(readelf -d "$GAMEDIR/bin/$AGSBIN" 2>/dev/null | grep -oE 'libSDL2[^]]*' | head -1 || echo '<static>')"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "/dev/dri:"; ls -l /dev/dri 2>/dev/null || echo "  (none)"

$ESUDO chmod +x "$GAMEDIR/bin/$AGSBIN" "$GAMEDIR/bin/validate-game-files" 2>/dev/null
echo "engine: $AGSBIN -> $("$GAMEDIR/bin/$AGSBIN" --version 2>/dev/null | tail -1)"

# ArkOS ALSA dmix fix
[[ "$CFW_NAME" == *"ArkOS"* ]] && [ -f "$GAMEDIR/asoundrc" ] && cp "$GAMEDIR/asoundrc" "$HOME/.asoundrc"

VAL="$(bash "$GAMEDIR/bin/validate-game-files" "$GAMEDIR/gamedata" 2>&1)"; echo "$VAL"
MAIN="$(printf '%s\n' "$VAL" | sed -n 's/^RESULT_MAIN=//p' | tail -n1)"; [ -z "$MAIN" ] && MAIN="TheCatLady.exe"

$GPTOKEYB "$AGSBIN" -c "$GAMEDIR/thecatlady.gptk" &
pm_platform_helper "$GAMEDIR/bin/$AGSBIN" 2>/dev/null

echo "----- launching $AGSBIN (gfx=$GFX) -----"
# --log-stdout mirrors the engine log into our tee'd log.txt (one file has it
# all); --log-file-path also keeps a clean engine-only log under logs/.
"$GAMEDIR/bin/$AGSBIN" \
    --no-plugins --fullscreen --gfxdriver "$GFX" \
    --log-file-path "$GAMEDIR/logs/ags.log" --log-file=all:info --log-stdout=all:info \
    "$GAMEDIR/gamedata/$MAIN"
echo "----- $AGSBIN exited: $? -----"

pm_finish
