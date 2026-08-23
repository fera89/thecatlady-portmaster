#!/bin/bash
# The Cat Lady - native GLES2 engine (GPU-accelerated on the Mali). Uses a
# separate binary (bin/ags-gles2) with AGS's OpenGL-ES2 renderer.
export TCL_TAG="gles2"
export TCL_GFXDRIVER="ogl"
export TCL_AGS_BIN="ags-gles2"
source "$(dirname "$0")/thecatlady/run.sh"
