# The Cat Lady — PortMaster port (R36S / RK3326)

A **native AArch64** port of *The Cat Lady* (Harvester Games) for **PortMaster**,
built and verified on the **R36S** handheld (Rockchip RK3326). It runs the game on
an open-source **Adventure Game Studio 3.6.x** engine compiled for ARM — **no x86
emulation, no Box86/Box64**.

> This repository contains **only** the port: the ARM engine, launcher, config,
> controls, docs and PortMaster metadata. It contains **none** of the game's data.
> You must own a copy of The Cat Lady and copy your own game files onto the device.
> See [Installing the game files](#installing-the-game-files).

## Status: ✅ working on device

Boots to the menu and plays through on the R36S with GPU-accelerated video,
audio, saves, controller mapping, quick save/load and persistent language
selection. See [STATUS.md](STATUS.md) for the full build/verification report.

## Key facts (verified on hardware)

| Thing | Value |
|---|---|
| Engine | AGS `3.6.2.21`, built for aarch64 in **native GLES2 mode** |
| Renderer | OpenGL ES2 on the Mali-G31 (GPU-accelerated) |
| Game native resolution | 800×600, 32-bit, 4:3 |
| R36S panel | 640×480, 4:3 → uniform **0.8× downscale**, no distortion, no bars |
| glibc requirement | ≤ 2.30 (safe on ArkOS / dArkOS and newer) |
| Steam plugin | not used; built-in stubs via `--no-plugins` |

## Controls (R36S buttons)

| Button | Action in game |
|---|---|
| **D-pad / Left stick** | Move cursor (arrow keys) |
| **A** | Confirm / interact (Enter) |
| **B** or **Start** | Back / menu (Esc) |
| **X** | Skip dialogue (Space) |
| **Y** / **R1** | Interact (Up) |
| **L1** | Inventory (Down) |
| **L2** | Quick **save** (F1) |
| **R2** | Quick **load** (F5) |

Full notes: [docs/CONTROLS.md](docs/CONTROLS.md).

## Install (the easy way)

1. Download the latest **`thecatlady-portmaster.zip`** from
   [Releases](../../releases).
2. Unzip into your device's `/roms/ports/` (or `ports/` on the ports partition).
3. Copy your own game files into `ports/thecatlady/gamedata/`
   (see [Installing the game files](#installing-the-game-files)).
4. Launch **The Cat Lady** from the PortMaster / Ports menu.

## Installing the game files

This port does **not** include the game. Copy the data from your own copy
(Steam **app 253110**) into `thecatlady/gamedata/`. AGS data is
platform-independent, so **Windows or Linux files both work**:

**Required:** `TheCatLady.ags` (Linux) *or* `TheCatLady.exe` (Windows), plus
`audio.vox` and `speech.vox`.
**Also copy if present:** `TheCatLady.001` / `.002`, and any `*.tra`
(e.g. `Portuguese.tra`).
**Do not copy:** `ags32`, `ags64`, `lib32/`, `lib64/`, `agsteam.dll`, `steam_api.dll`.

Step-by-step with screenshots of the file list:
[docs/STEAM_FILES.md](docs/STEAM_FILES.md) and
[port/thecatlady/README.md](port/thecatlady/README.md).

## Build it yourself

You do **not** need the game to build the engine/package. The ARM engine build
system lives in the companion **[ags-portmaster-runtime](https://github.com/fera89/ags-portmaster-runtime)**
repo; this port bundles the resulting binary. To rebuild locally:

```bash
./scripts/fetch-ags.sh && ./scripts/build-ags-aarch64.sh && ./scripts/stage-runtime.sh
```

Full details: [docs/BUILD.md](docs/BUILD.md).

## Layout

```
thecatlady-portmaster/
├── scripts/        build / stage / validate / audit / package
├── docker/         arm64 build container
├── toolchains/     aarch64 CMake toolchain (direct cross-compile)
├── runtime/        R36S acsetup.cfg defaults + gptokeyb controls
├── patches/ags/    engine patches (native GLES2, persist user config)
├── port/thecatlady manifest, launcher, and the installed layout
├── docs/           architecture, build, device testing, compatibility…
└── upstream/       pinned AGS version record
```

## Legal

Open-source runtime (AGS, Artistic License 2.0) + your own legally-owned game
data. No proprietary assets are redistributed; no DRM is circumvented. The port
is marked **not Ready to Run** in PortMaster metadata. See [LICENSES.md](LICENSES.md).

## Acknowledgements

- **Harvester Games** — *The Cat Lady*.
- The **Adventure Game Studio** team — the open-source engine (Artistic License 2.0).
- The **PortMaster** community — conventions, `gptokeyb`, and the working ports
  that made the RK3326/Mali display and audio quirks solvable.
- Built with the help of **Claude Code** (Anthropic) as a pair-programming
  assistant for the ARM build, the Mali GLES2 fix and the config-persistence fix.
