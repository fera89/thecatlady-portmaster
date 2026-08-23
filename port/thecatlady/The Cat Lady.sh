#!/bin/bash
# The Cat Lady — native GLES2 renderer (GPU-accelerated on the RK3326 Mali).
# This is the default and only launcher. The engine binary (bin/ags) is the
# GLES2 build; if the GL context ever fails it falls back to software.
export TCL_TAG="tcl"
export TCL_GFXDRIVER="ogl"
source "$(dirname "$0")/thecatlady/run.sh"
