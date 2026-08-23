#!/bin/bash
# The Cat Lady — same as the default (system SDL2 + software + performance
# governor) but with vsync disabled, to A/B test framerate vs tearing.
# Logs: thecatlady/logs/run-sys-novsync.log
export TCL_TAG="sys-novsync"
export TCL_GFXDRIVER="software"
export TCL_VSYNC="0"
source "$(dirname "$0")/thecatlady/run.sh"
