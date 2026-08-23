#!/bin/bash
# The Cat Lady — software renderer, forcing SDL's EGL to the Mali blob so the
# window/GBM surface is created by the Mali driver (not mesa).
# Logs: thecatlady/logs/run-sys-malisw.log and ags-sys-malisw.log
export TCL_TAG="sys-malisw"
export TCL_GFXDRIVER="software"
export TCL_SDL_EGL_DRIVER="/usr/lib/aarch64-linux-gnu/libmali.so.1"
source "$(dirname "$0")/thecatlady/run.sh"
