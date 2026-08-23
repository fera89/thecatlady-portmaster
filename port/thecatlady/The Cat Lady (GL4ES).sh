#!/bin/bash
# The Cat Lady — system SDL2 + GL4ES OpenGL (desktop-GL translation to Mali GLES).
# Logs: thecatlady/logs/run-sys-gl4es.log and ags-sys-gl4es.log
export TCL_TAG="sys-gl4es"
export TCL_GL4ES="1"
export TCL_GFXDRIVER="ogl"
source "$(dirname "$0")/thecatlady/run.sh"
