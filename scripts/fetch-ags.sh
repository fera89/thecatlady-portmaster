#!/usr/bin/env bash
# Fetch the pinned Adventure Game Studio source into upstream/ags (spec §36 Step 2).
# Idempotent: re-running checks out the pinned commit again.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=./versions.env
source "$HERE/versions.env"

DEST="$ROOT/upstream/ags"

echo "== Fetching AGS $AGS_VERSION ($AGS_GIT_TAG @ ${AGS_GIT_COMMIT:0:12}) =="

if [ ! -d "$DEST/.git" ]; then
    git clone --no-checkout "$AGS_REPO" "$DEST"
fi

cd "$DEST"
git fetch --tags origin
git checkout --detach "$AGS_GIT_COMMIT"

# Verify we are exactly on the pinned commit.
ACTUAL="$(git rev-parse HEAD)"
if [ "$ACTUAL" != "$AGS_GIT_COMMIT" ]; then
    echo "ERROR: expected $AGS_GIT_COMMIT but HEAD is $ACTUAL" >&2
    exit 1
fi

# Pull submodules if the pinned tree uses any (SDL2 etc. may be vendored).
git submodule update --init --recursive

# Apply any local patches (spec §8 patches/ags). None are required by default.
shopt -s nullglob
for p in "$ROOT"/patches/ags/*.patch; do
    echo "-- applying patch: $(basename "$p")"
    git apply --3way "$p"
done
shopt -u nullglob

echo "[OK] AGS source ready at $DEST (HEAD=$ACTUAL)"
