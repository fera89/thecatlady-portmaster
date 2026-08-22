# Building the ARM engine and package

You do **not** need The Cat Lady game data to build the engine or the package.
Everything is driven by the single version pin in
[`scripts/versions.env`](../scripts/versions.env).

There are three supported paths. Pick the one that matches your machine.

---

## Path A — Docker (recommended on Windows/macOS/Linux)

Builds a genuine `aarch64` engine inside an emulated arm64 container (QEMU),
which avoids all cross-toolchain/sysroot friction.

**Requires:** Docker Desktop (buildx + QEMU are included by default).

```bash
./scripts/docker-build.sh
```

This fetches AGS at the pinned commit, compiles the engine (video enabled),
bundles its non-system `.so` deps, stages everything into
`port/thecatlady/thecatlady/`, and runs the architecture audit.

Then package:

```bash
./scripts/make-portmaster-package.sh      # -> dist/thecatlady-r36s-YYYYMMDD.zip
```

> On Windows, run these from Git-Bash or WSL. The `.sh` scripts are POSIX shell.

---

## Path B — GitHub Actions (no local install)

Push this repository to GitHub. The [`build-arm64-port`](../.github/workflows/build.yml)
workflow:

1. blocks the build if any proprietary game file is tracked,
2. builds the arm64 engine (same Docker path),
3. runs the architecture audit,
4. verifies licenses,
5. uploads `dist/*.zip` as a build artifact (**never** game data).

Download the artifact from the workflow run and install it via PortMaster.

---

## Path C — Direct cross-compile (x86_64 Linux / WSL2)

**Requires:** `aarch64-linux-gnu-gcc/g++`, `cmake`, `ninja`, and arm64 dev
libraries for SDL2/ogg/vorbis/theora (a sysroot or multiarch install).

```bash
./scripts/fetch-ags.sh            # clone + checkout pinned commit
./scripts/build-ags-aarch64.sh    # cmake cross build via toolchains/aarch64-linux-gnu.cmake
./scripts/stage-runtime.sh        # copy engine/libs/config/controls/licenses into the port
./scripts/audit-arch.sh           # mandatory arch check
./scripts/make-portmaster-package.sh
```

Tuning (only **after** a working baseline, spec §11): re-run the build with
`-DEXTRA_CMAKE_ARGS` or edit the toolchain to add `-mcpu=cortex-a35`, then
benchmark on device before keeping it.

---

## CMake options used (spec §12)

Verified against the pinned release's `CMAKE.md`:

```
-DAGS_BUILD_ENGINE=ON      # engine only
-DAGS_BUILD_TOOLS=OFF
-DAGS_BUILD_COMPILER=OFF
-DAGS_TESTS=OFF
# AGS_NO_VIDEO_PLAYER left OFF  -> video stays enabled (spec §7)
```

## Verifying the result

```bash
file  port/thecatlady/thecatlady/bin/ags     # -> ELF 64-bit ... ARM aarch64
port/thecatlady/thecatlady/bin/ags --version # -> 3.6.2.21
```

## Difference from the spec's assumed layout

The spec assumed the Linux depot (`TheCatLady.ags` + `ags32/ags64/lib32/lib64`).
Real installs are commonly the **Windows** build (`TheCatLady.exe` + `.001/.002`).
The validator and launcher handle both; nothing in the build changes.
