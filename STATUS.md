# STATUS

Progress report in the spec §36 format. Updated 2026-08-24.
**Outcome: the port is playable on the R36S** — see
[VERIFIED ON DEVICE](#verified-on-device--playable-2026-08-24) at the bottom.

Build environment: **WSL2 Ubuntu 24.04** (x86_64) with an aarch64 cross toolchain
+ qemu-user-static; the device-target engine is built in a **Debian bullseye
arm64 chroot** (glibc 2.31) for a ≤ 2.30 glibc requirement. Verified on a
physical **R36S**.

---

## DONE

- **Milestone 1 — desktop x86_64 validation. PASS.** Built AGS 3.6.2.21 for
  x86_64 in WSL and booted it headless against the user's real Steam data: reads
  the Windows `TheCatLady.exe` embedded data ("game28.dta", made with AGS
  3.4.1.11), finds `speech.vox` + `audio.vox`, reaches "Engine initialization
  complete" → "Starting game". No data modified.
- **Milestone 2 — AGSteam independence. PASS.** With `--no-plugins` the engine
  reports *"Placeholder functions for the plugin 'agsteam' found"* (built-in
  stub) and `agsblend` built-in. `agsd3dvsync` has no stub but the game does not
  import it, so boot is unaffected. Achievements unavailable, gameplay fine.
- **Milestone 3 — aarch64 engine build. PASS.** Cross-compiled to
  `ELF 64-bit ... ARM aarch64` (multiarch + qemu for CMake try_run). Dynamic
  deps are core-only: `libstdc++, libm, libgcc_s, libc, ld-linux-aarch64` —
  SDL2/ogg/vorbis/theora are statically linked, so **no `.so` bundling needed**.
- **Milestone 4 — AGS ARM smoke test (under qemu emulation). PASS.** The arm64
  binary loads The Cat Lady and reaches "Starting game" exactly like x86_64.
- **Device-target build. PASS.** Rebuilt the engine in a Debian bullseye arm64
  chroot (gcc-10) with `-static-libstdc++ -static-libgcc` and `SDL_WAYLAND=OFF`.
  Result verified: `ELF aarch64`, **max GLIBC required = 2.30** (<= device 2.31),
  **no GLIBCXX/SDL2 runtime deps** (NEEDED = libdl/libm/libpthread/libc only).
  Smoke-tested under qemu: reaches "Starting game" on the real Steam data.
- **Packaging. PASS.** `dist/thecatlady-r36s-*.zip` (3.0 MB) built by the repo
  scripts; architecture audit passes; no proprietary data; licenses included.
- **Installed on the user's actual R36S card. PASS.** Copied the port to
  `/roms/ports/` (EASYROMS/exFAT): launcher + engine + config + gptk + asoundrc +
  licenses, and the user's game data (1.39 GB) into `gamedata/`. The installed
  validator confirms all data on-card; all scripts/configs are LF.
- **Milestone 0 — repository bootstrap.** Full tree, `.gitignore`, README,
  version pin, all scripts, PortMaster skeleton, docs.
- **Version pin (Step 2).** AGS `3.6.2.21` @ `810192970…` recorded with the
  fallback matrix in [upstream/README.md](upstream/README.md) and
  [scripts/versions.env](scripts/versions.env).
- **Game facts captured (not assumed).** Native **800×600 / 32-bit / 4:3** read
  from the Steam `acsetup.cfg` → clean **0.8× downscale** to 640×480, no aspect
  distortion. Config in [runtime/config/acsetup-r36s.cfg](runtime/config/acsetup-r36s.cfg).
- **Data-layout reality handled.** The installed Steam copy is the **Windows**
  build (`TheCatLady.exe` + `.001/.002` + `audio.vox` + `speech.vox` + `*.tra`),
  not the Linux depot. Validator + launcher accept **either** layout because AGS
  data is platform-independent.
- **Build system (all three paths).** Docker arm64 build, direct cross-compile,
  and GitHub Actions CI — all wired to the single version pin.
- **Architecture audit** ([scripts/audit-arch.sh](scripts/audit-arch.sh)) — fails
  on any x86/x86_64 binary; enforced in packaging and CI (spec §14, §32).
- **Game-file validation** (spec §10), **launcher** with `LD_LIBRARY_PATH`, XDG
  save/log redirection, controls, logging and clean-exit trap (spec §17–20).
- **Controls** — provisional gptokeyb profile (mouse-cursor + common keys),
  flagged for on-device verification (spec §19).
- **PortMaster metadata** — `port.json` (`rtr:false`, `arch:["aarch64"]`, Steam
  store link), `gameinfo.xml`, user README (spec §24, §34).
- **Docs** — architecture, build, device testing, Steam files, compatibility
  matrix, controls, troubleshooting.

## Device target — CONFIRMED

Inspected the user's actual R36S SD card:
- Device **R36S / RK3326**, **ArkOS** (dArkOS/arkos4clone base = Ubuntu focal),
  PortMaster 2024.07.17 installed, `/roms` on the exFAT EASYROMS partition.
- **glibc 2.31** — established empirically (working ports need up to glibc 2.30:
  undertale 2.30, gptokeyb 2.29) and from the ArkOS base (focal). Target locked
  to **glibc 2.31**.
- Launcher verified against the device's real `control.txt` + working port
  launchers (undertale.sh, render96ex.sh): `directory=roms`, `get_controls`,
  `$GPTOKEYB ... -c x.gptk`, `pm_platform_helper`, `pm_finish`, and the ArkOS
  `~/.asoundrc` dmix audio fix — all incorporated.

The engine is therefore built in a **Debian bullseye (glibc 2.31) arm64** chroot
with `-static-libstdc++ -static-libgcc` and `SDL_WAYLAND=OFF`, so the only runtime
dependency is glibc <= 2.31 (safe on this device and newer). The earlier Ubuntu
24.04 (glibc 2.39) binary was correct for validation but is being rebuilt on this
target for the actual device package.

## On-device findings

- **First boot (2026-08-23):** audio played (ALSA/asoundrc OK) but the screen
  stayed on the console (black + blinking cursor). Diagnosed: the bundled SDL2
  had only `x11/offscreen/dummy` video drivers — **no KMSDRM** — so on ArkOS
  (no X11) SDL reported "No available video device". Fix: rebuild SDL2 with
  `SDL_KMSDRM=ON` (+ libdrm/gbm/udev dev in the chroot).
- **Second boot (KMSDRM engine):** SDL still could not present. Engine log:
  `Can't window GBM/EGL surfaces on window creation` (OpenGL) and
  `SDLRenderer ... 'renderer' is invalid` (software, which also uses GLES on
  KMSDRM). The game itself ran fine (loaded room 27, decoded the Theora intro,
  wrote a save) — only the display never reached the panel. Kernel is 4.4.189
  and the Mali blob provides fbdev EGL, not GBM/KMS EGL that SDL's KMSDRM needs.
- **Fix: GL4ES.** The working ports here (Penumbra, Perfect Dark) render via
  GL4ES, which builds a Mali-compatible EGL context. Built an **aarch64 GL4ES**
  (libGL+libEGL, glibc <=2.27) and bundled it as `thecatlady/gl4es.aarch64/`.
  The runner sources PortMaster's `libgl_default.txt` and points
  `SDL_VIDEO_GL_DRIVER`/`SDL_VIDEO_EGL_DRIVER` at GL4ES, then runs AGS with
  `--gfxdriver ogl` — mirroring Penumbra.
- **4 launcher variants** (each logs to `run-<tag>.log`/`ags-<tag>.log`):
  `The Cat Lady` (GL4ES+ogl, primary), `(GL4ES FB2)` (LIBGL_FB=2),
  `(GL4ES KMS)` (force SDL kmsdrm), `(Software)` (no GL4ES, reference).

- **WORKING ON DEVICE (2026-08-23):** `The Cat Lady` (system SDL2 + AGS
  software renderer) boots to the menu and plays in-game on the R36S. The fix
  was `AGS_USE_LOCAL_SDL2=ON` — the device's own libSDL2 (2.32.10 via LD_PRELOAD)
  drives the RK3326/Mali display via its `opengles2` renderer; our bundled SDL2
  could not. Audio, saves, translations all work.
- **Optimization pass:** software rendering of 800×600 on the Cortex-A35 is
  CPU-bound (ALSA underruns in the log). Added: **CPU/GPU performance governor**
  (`perf-governor.inc`, restored on exit) — the main lever; scaling filter set
  to `stdscale` (GPU-side, cheap); per-run memory logging (`logs/mem-*.log`) to
  size the sprite cache from real `VmHWM`/free-RAM data; and a `(vsync off)`
  launcher for A/B testing. Sprite cache kept at 128 MB pending the memory log.

- **GPU rendering solved (2026-08-23).** AGS's OpenGL renderer wouldn't create a
  window on this Mali (desktop-GL path). Built AGS in **native GLES2 mode**
  (`AGS_OPENGL_ES2` + CMake `AGS_OPENGLES2`, patch in `patches/ags/`), which asks
  for an EGL/GLES2 context the Mali provides natively — **GPU-accelerated, runs
  great on device** (this was the real performance fix; GL4ES was never needed).
- **Finalised to one launcher.** `The Cat Lady` = the GLES2 build (`bin/ags`),
  `--gfxdriver ogl`. Removed the software/GL4ES/diagnostic launchers and the
  gl4es libs. Controls remapped to the game's real keys (A=Enter, B/Start=Esc,
  X=Space, dpad/stick=arrows) and documented in R36S-button terms
  (README + docs/CONTROLS.md). `antialias=1` for smoother text.

## VERIFIED ON DEVICE — playable (2026-08-24)

Signed off on the user's physical R36S (ArkOS / dArkOS base):

- **M5 boot / M6 controls / M7 gameplay — PASS.** Boots to the menu at 640×480,
  GPU-accelerated via the native GLES2 build; rooms, dialogue, inventory, speech,
  music, SFX and the Theora intro all play. Final controller mapping
  (A=Enter, B/Start=Esc, X=Space, Y/R1=Up, L1=Down, d-pad/stick=arrows) verified
  and documented in R36S-button terms (README + docs/CONTROLS.md).
- **Quick save / load — PASS.** `L2 = F1` (quick **save**), `R2 = F5` (quick
  **load**) — sidesteps the on-screen save-name prompt (no keyboard on the
  handheld). Confirmed working on device.
- **Persistent language — PASS.** Ships in **English** by default; the player's
  in-game language choice now **persists across launches**. This needed two
  engine/launcher fixes:
  1. **Write the choice.** Upstream gates `save_config_file()` behind
     `AGS_AUTO_WRITE_USER_CONFIG` (never defined, no implementation), so the user
     config was never written on exit. Patched `quit()` to call
     `save_runtime_config_file()` on normal exit → writes
     `language/translation` to `saves/ags/<game>/acsetup.cfg`
     (`patches/ags/0002-persist-user-config-on-exit.patch`).
  2. **Read the choice back.** The launcher used `--conf`, but AGS's
     `engine_read_config()` reads *only* that file and skips the user config
     (early `return`). Dropped `--conf`; the launcher now seeds the tuned
     defaults into `gamedata/acsetup.cfg` (the engine's StartupDir config), and
     the user config is layered on top — so the saved language wins.

## Optional polish (not blocking)

- Sprite-cache tuning from real `VmRSS`/`VmHWM` (kept at the 128 MB game default;
  runs fine as-is).
- Add `screenshot.png` / `cover.png` before any PortMaster submission.
