#!/bin/bash
# The Cat Lady — GL4ES + OpenGL, forcing SDL_VIDEODRIVER=kmsdrm.
# Logs: thecatlady/logs/run-gl4es-kms.log and ags-gl4es-kms.log
export TCL_TAG="gl4es-kms"
export TCL_GL4ES="1"
export TCL_GFXDRIVER="ogl"
export TCL_SDL_VIDEODRIVER="kmsdrm"
source "$(dirname "$0")/thecatlady/run.sh"
