#!/bin/bash
# The Cat Lady — KMSDRM video + AGS OpenGL renderer.
# Logs: thecatlady/logs/run-kmsdrm-gl.log and ags-kmsdrm-gl.log
export TCL_TAG="kmsdrm-gl"
export TCL_SDL_VIDEODRIVER="kmsdrm"
export TCL_GFXDRIVER="ogl"
source "$(dirname "$0")/thecatlady/run.sh"
