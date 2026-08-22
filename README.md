# The Cat Lady — R36S / PortMaster port

A **native AArch64** port of *The Cat Lady* (Harvester Games) for the **R36S**
handheld (Rockchip RK3326), distributed through **PortMaster**. It runs the game
on an open-source **Adventure Game Studio 3.6.x** engine compiled for ARM — **no
x86 emulation, no Box86/Box64**.

> This repository contains **only** the port: the ARM engine build system,
> launcher, config, controls, docs and PortMaster metadata. It contains **none**
> of the game's data. You must own a copy of The Cat Lady and copy your own game
> files onto the device. See [Installing the game files](#installing-the-game-files).

## Status

See [STATUS.md](STATUS.md) for the live milestone report. In short: the full port
scaffold, build system (Docker + CI), launcher, validation, config and docs are
complete; the ARM engine build runs in Docker/CI; on-device milestones (boot,
controls, gameplay) need a physical R36S to sign off.

## Key facts (verified, not assumed)

| Thing | Value | Source |
|---|---|---|
| Engine | AGS `3.6.2.21` (pinned commit) | [upstream/README.md](upstream/README.md) |
| Game native resolution | **800×600, 32-bit, 4:3** | Steam `acsetup.cfg` |
| R36S panel | 640×480, 4:3 | hardware |
| Scaling | uniform **0.8× downscale**, no distortion, no bars | derived |
| Renderer (default) | Software (spec §15) | this port |
| Steam plugin | not used; built-in stubs via `--no-plugins` | spec §6 |

## Build it (pick one)

You do **not** need The Cat Lady to build the engine/package.

- **Docker (local, recommended):**
  ```bash
  ./scripts/docker-build.sh
  ```
- **GitHub Actions (cloud, zero install):** push to GitHub; the
  [`build-arm64-port`](.github/workflows/build.yml) workflow produces the
  PortMaster zip as an artifact.
- **Direct cross-compile** (x86_64 Linux/WSL2 with an aarch64 toolchain):
  ```bash
  ./scripts/fetch-ags.sh && ./scripts/build-ags-aarch64.sh && ./scripts/stage-runtime.sh
  ```

Full details: [docs/BUILD.md](docs/BUILD.md).

## Installing the game files

This port does **not** include the game. Copy the data from your own copy
(Steam app **253110**) into `thecatlady/gamedata/`. AGS data is
platform-independent, so **Windows or Linux files both work**:

**Required:** `TheCatLady.ags` (Linux) *or* `TheCatLady.exe` (Windows), plus
`audio.vox` and `speech.vox`.
**Also copy if present:** `TheCatLady.001` / `.002`, and any `*.tra`
(e.g. `Portuguese.tra`).
**Do not copy:** `ags32`, `ags64`, `lib32/`, `lib64/`, `agsteam.dll`, `steam_api.dll`.

See [port/thecatlady/README.md](port/thecatlady/README.md) and
[docs/STEAM_FILES.md](docs/STEAM_FILES.md).

## Deploy to the R36S

1. Build the package (above) → `dist/thecatlady-r36s-YYYYMMDD.zip`.
2. Install it via PortMaster (or unzip into `/roms/ports/`).
3. Copy your game files into `/roms/ports/thecatlady/gamedata/`.
4. Launch **The Cat Lady** from the Ports menu.

Exact commands and on-device checks: [docs/DEVICE_TESTING.md](docs/DEVICE_TESTING.md).

## Layout

```
thecatlady-r36s/
├── scripts/        build / stage / validate / audit / package
├── docker/         arm64 build container
├── toolchains/     aarch64 CMake toolchain (direct cross-compile)
├── runtime/        R36S acsetup.cfg override + gptokeyb controls
├── port/thecatlady manifest, launcher, and the installed layout
├── docs/           architecture, build, device testing, compatibility…
└── upstream/       pinned AGS version record
```

## Legal

Open-source runtime (AGS, Artistic License 2.0) + your own legally-owned game
data. No proprietary assets are redistributed; no DRM is circumvented. The port
is marked **not Ready to Run** in PortMaster metadata. See [LICENSES.md](LICENSES.md).
