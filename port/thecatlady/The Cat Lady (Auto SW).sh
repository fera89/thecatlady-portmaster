#!/bin/bash
# The Cat Lady — SDL auto-detect video + AGS software renderer.
# Logs: thecatlady/logs/run-auto-sw.log and ags-auto-sw.log
export TCL_TAG="auto-sw"
export TCL_SDL_VIDEODRIVER=""
export TCL_GFXDRIVER="software"
source "$(dirname "$0")/thecatlady/run.sh"
