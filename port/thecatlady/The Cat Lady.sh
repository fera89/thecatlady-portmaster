#!/bin/bash
# The Cat Lady — GL4ES + OpenGL (primary path for this RK3326/Mali device).
# Mirrors how the working ports (Penumbra, Perfect Dark) render here.
# Logs: thecatlady/logs/run-gl4es-ogl.log and ags-gl4es-ogl.log
export TCL_TAG="gl4es-ogl"
export TCL_GL4ES="1"
export TCL_GFXDRIVER="ogl"
source "$(dirname "$0")/thecatlady/run.sh"
