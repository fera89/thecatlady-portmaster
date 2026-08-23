#!/bin/bash
# The Cat Lady — system SDL2 + AGS software renderer (primary).
# Uses the device's own libSDL2 (which drives the RK3326/Mali display), like the
# working ports here. Logs: thecatlady/logs/run-sys-sw.log and ags-sys-sw.log
export TCL_TAG="sys-sw"
export TCL_GFXDRIVER="software"
source "$(dirname "$0")/thecatlady/run.sh"
