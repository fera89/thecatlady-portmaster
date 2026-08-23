#!/bin/bash
# The Cat Lady — no GL4ES, AGS software renderer (reference/fallback).
# Logs: thecatlady/logs/run-soft.log and ags-soft.log
export TCL_TAG="soft"
export TCL_GFXDRIVER="software"
source "$(dirname "$0")/thecatlady/run.sh"
