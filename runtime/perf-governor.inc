#!/bin/bash
# Pin CPU/GPU/DMC governors to "performance" for this launcher session and
# restore the previous values on exit. Sourced by run.sh after control.txt
# (needs $ESUDO). Self-contained so the port does not depend on external files.

_TCL_GOV_NODES=()
_TCL_GOV_PREV=()

_tcl_gov_write() {
  local node="$1" value="$2"
  if [ -w "$node" ]; then
    printf '%s\n' "$value" > "$node" 2>/dev/null
  else
    ${ESUDO:-} sh -c "printf '%s\n' '$value' > '$node'" 2>/dev/null
  fi
}

_tcl_gov_set_performance() {
  local node prev
  for node in \
      /sys/devices/system/cpu/cpufreq/policy*/scaling_governor \
      /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor \
      /sys/class/devfreq/*/governor; do
    [ -f "$node" ] || continue
    grep -qw performance "${node%/*}/scaling_available_governors" "${node%/*}/available_governors" 2>/dev/null || true
    prev="$(cat "$node" 2>/dev/null)"
    [ -n "$prev" ] || continue
    [ "$prev" = "performance" ] && continue
    _tcl_gov_write "$node" performance
    if [ "$(cat "$node" 2>/dev/null)" = "performance" ]; then
      _TCL_GOV_NODES+=("$node")
      _TCL_GOV_PREV+=("$prev")
    fi
  done
  echo "governor: pinned ${#_TCL_GOV_NODES[@]} node(s) to performance"
}

_tcl_gov_restore() {
  local i
  for i in "${!_TCL_GOV_NODES[@]}"; do
    _tcl_gov_write "${_TCL_GOV_NODES[$i]}" "${_TCL_GOV_PREV[$i]}"
  done
}

_tcl_gov_set_performance
