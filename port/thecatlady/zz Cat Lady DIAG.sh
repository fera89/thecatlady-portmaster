#!/bin/bash
# Diagnostic launcher — does NOT run the game. Collects device display/SDL info
# into thecatlady/logs/diag.txt so we can pick the right rendering path.
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if   [ -d "/opt/system/Tools/PortMaster/" ]; then controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ];       then controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ];    then controlfolder="$XDG_DATA_HOME/PortMaster"
else controlfolder="/roms/ports/PortMaster"; fi
source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/thecatlady"
mkdir -p "$GAMEDIR/logs"
OUT="$GAMEDIR/logs/diag.txt"

SDLLIB="$(ls /usr/lib/libSDL2-2.0.so.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 /usr/local/lib/libSDL2-2.0.so.0 2>/dev/null | head -1)"

{
echo "==== The Cat Lady device diagnostic  $(date '+%F %T') ===="
echo "## uname";        uname -a
echo "## os-release";   cat /etc/os-release 2>/dev/null
echo "## glibc";        ldd --version 2>/dev/null | head -1
echo "## CFW";          echo "CFW_NAME=$CFW_NAME DEVICE=$DEVICE_NAME ARCH=$DEVICE_ARCH ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT} directory=$directory"
echo
echo "## system libSDL2 (path/version/video-drivers) -- THE KEY INFO"
echo "SDLLIB=$SDLLIB"
find /usr /lib -maxdepth 4 -iname 'libSDL2*' 2>/dev/null
echo "-- SDL version string --"
strings -a "$SDLLIB" 2>/dev/null | grep -oE 'SDL-2\.[0-9]+\.[0-9]+[^ ]*' | sort -u | head
echo "-- video drivers compiled into the SYSTEM SDL2 --"
strings -a "$SDLLIB" 2>/dev/null | grep -ixE 'kmsdrm|x11|wayland|offscreen|dummy|rpi|vivante|mali|fbdev|fbcon|directfb|rockchip' | sort -u | tr '\n' ' '; echo
echo
echo "## DRM / framebuffer"
ls -la /dev/dri 2>/dev/null; ls -la /dev/fb* 2>/dev/null
echo "-- who holds /dev/dri/card0 (is ES keeping DRM master?) --"
$ESUDO fuser -v /dev/dri/card0 2>&1
echo "-- running display processes --"
ps -e 2>/dev/null | grep -iE 'emulationstation|es-|gptokeyb|Xorg|weston|sway' | grep -v grep
echo
echo "## EGL / GLES / mali libs on device"
find /usr/lib -maxdepth 3 \( -iname 'libEGL*' -o -iname 'libGLESv2*' -o -iname 'libmali*' -o -iname 'libgbm*' \) 2>/dev/null
echo
echo "## how a working GL port renders (undertale gmloader.json)"
cat "/$directory/ports/undertale/gmloader.json" 2>/dev/null
echo
echo "## SDL_VIDEODRIVER / hints exported by control.txt+mod (grep)"
grep -rIhE 'SDL_VIDEODRIVER|SDL_VIDEO_|SDL_HINT|/dev/fb|weston|xinit' "$controlfolder"/control.txt "$controlfolder"/mod_${CFW_NAME}.txt 2>/dev/null | grep -iv '^#' | sort -u | head -30
echo "==== end ===="
} > "$OUT" 2>&1
sync
# tiny on-screen hint via message box if available
command -v pm_message >/dev/null 2>&1 && pm_message "Diagnostic written to thecatlady/logs/diag.txt . Reconnect the SD card to the PC."
