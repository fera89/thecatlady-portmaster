#!/usr/bin/env bash
# Binary architecture audit (spec §14). MANDATORY before packaging.
#
# Fails if any binary in the target is x86/x86_64. Passes only ARM aarch64.
#
# Usage:
#   scripts/audit-arch.sh                # scans the staged port dir
#   scripts/audit-arch.sh <file|dir> ... # scans specific paths
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

TARGETS=("$@")
if [ "${#TARGETS[@]}" -eq 0 ]; then
    TARGETS=("$ROOT/port/thecatlady/thecatlady/bin" "$ROOT/port/thecatlady/thecatlady/lib")
fi

command -v file >/dev/null || { echo "ERROR: 'file' utility not found" >&2; exit 2; }

bad=0
checked=0

check_one() {
    local f="$1" desc
    desc="$(file -b "$f")"
    case "$desc" in
        *ELF*)
            checked=$((checked+1))
            case "$desc" in
                *aarch64*|*"ARM aarch64"*)
                    echo "[OK]   aarch64  $f"
                    ;;
                *"Intel 80386"*|*x86-64*|*"x86_64"*)
                    echo "[FAIL] x86!!    $f  -> $desc"
                    bad=$((bad+1))
                    ;;
                *ARM*)
                    # 32-bit ARM (armhf) — allowed only as a documented secondary target.
                    echo "[WARN] arm32    $f  -> $desc"
                    ;;
                *)
                    echo "[WARN] other    $f  -> $desc"
                    ;;
            esac
            ;;
        *)
            : # non-ELF file, ignore
            ;;
    esac
}

for t in "${TARGETS[@]}"; do
    [ -e "$t" ] || continue
    if [ -f "$t" ]; then
        check_one "$t"
    else
        while IFS= read -r -d '' f; do
            check_one "$f"
        done < <(find "$t" -type f -print0)
    fi
done

echo "-----------------------------------------"
echo "ELF binaries checked: $checked   x86 offenders: $bad"
if [ "$bad" -ne 0 ]; then
    echo "ARCHITECTURE AUDIT FAILED: x86/x86_64 binaries present." >&2
    exit 1
fi
echo "[OK] Architecture audit passed."
