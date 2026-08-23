#!/bin/bash
# The Cat Lady — SDL auto-detect video + AGS OpenGL renderer.
# Logs: thecatlady/logs/run-auto-gl.log and ags-auto-gl.log
export TCL_TAG="auto-gl"
export TCL_SDL_VIDEODRIVER=""
export TCL_GFXDRIVER="ogl"
source "$(dirname "$0")/thecatlady/run.sh"
