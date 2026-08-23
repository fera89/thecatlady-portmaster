#!/bin/bash
# The Cat Lady — default profile: KMSDRM video + AGS software renderer.
# Logs: thecatlady/logs/run-kmsdrm-sw.log and ags-kmsdrm-sw.log
export TCL_TAG="kmsdrm-sw"
export TCL_SDL_VIDEODRIVER="kmsdrm"
export TCL_GFXDRIVER="software"
source "$(dirname "$0")/thecatlady/run.sh"
