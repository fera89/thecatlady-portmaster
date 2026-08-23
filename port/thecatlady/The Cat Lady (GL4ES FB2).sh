#!/bin/bash
# The Cat Lady — GL4ES + OpenGL, forcing LIBGL_FB=2 (surfaceless/pbuffer path)
# in case the default GBM framebuffer mode (FB=4) does not present here.
# Logs: thecatlady/logs/run-gl4es-fb2.log and ags-gl4es-fb2.log
export TCL_TAG="gl4es-fb2"
export TCL_GL4ES="1"
export TCL_GFXDRIVER="ogl"
export TCL_LIBGL_FB="2"
source "$(dirname "$0")/thecatlady/run.sh"
