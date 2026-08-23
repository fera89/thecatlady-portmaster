# Licenses

This port distributes an open-source runtime and original scripts/config only.
It does **not** distribute any of The Cat Lady's proprietary assets (spec §4, §25).

## This project's own files

The scripts, launcher, configuration, controller profiles, PortMaster metadata
and documentation in this repository are released under the **MIT License**
(unless a file states otherwise).

## Bundled / linked open-source components

Each component's upstream license text is staged into
`port/thecatlady/thecatlady/licenses/` by `scripts/stage-runtime.sh` and shipped
inside the PortMaster package.

| Component | License | Notes / source |
|---|---|---|
| Adventure Game Studio engine | Artistic License 2.0 | pinned `v3.6.2.21`, see [upstream/README.md](upstream/README.md) |
| SDL2 | zlib | bundled arm64 `.so` if not statically linked |
| libogg | BSD-3-Clause | Xiph.Org |
| libvorbis | BSD-3-Clause | Xiph.Org |
| libtheora | BSD-3-Clause | Xiph.Org (video, kept enabled per spec §7) |
| SDL_Sound / SDL2_sound | zlib / LGPL (per release) | only if the pinned AGS build links it |
| gptokeyb | GPL-3.0 | **provided by PortMaster on-device**, not bundled here |
| GL4ES (ptitSeb/gl4es) | MIT | bundled `gl4es.aarch64/` (libGL+libEGL); GL→GLES translation so the engine renders on the RK3326/Mali (native SDL KMSDRM can't make GBM/EGL surfaces here) |

> The exact set of bundled `.so` files depends on how the pinned AGS release
> links its dependencies (static vs shared). The build records every staged
> library; the architecture audit (spec §14) guarantees they are aarch64.

## Explicitly NOT distributed

`TheCatLady.ags`, `TheCatLady.exe`, `TheCatLady.00N`, `audio.vox`, `speech.vox`,
`*.tra`, and any Steam binaries (`libagsteam.so`, `agsteam.dll`, `steam_api.*`).
These come only from the user's own legally-owned copy.
