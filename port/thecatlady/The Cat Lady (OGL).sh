#!/bin/bash
# The Cat Lady — system SDL2 + AGS OpenGL (native, via device Mali GLES).
# Logs: thecatlady/logs/run-sys-ogl.log and ags-sys-ogl.log
export TCL_TAG="sys-ogl"
export TCL_GFXDRIVER="ogl"
source "$(dirname "$0")/thecatlady/run.sh"
