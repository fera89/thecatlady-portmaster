# Changelog

All notable changes to this port. Format loosely follows Keep a Changelog.

## [1.0.0] — 2026-08-24

First working release, verified on a physical R36S.

### Added
- **Native GLES2 engine build.** AGS 3.6.2.21 compiled for aarch64 in native
  OpenGL ES2 mode (`patches/ags/0001-allow-opengl-es2-override.patch`), giving
  GPU-accelerated rendering on the RK3326 Mali-G31.
- **Persistent language.** Engine patch
  (`patches/ags/0002-persist-user-config-on-exit.patch`) writes the player's
  language choice to the user config on normal exit; the launcher no longer uses
  `--conf` (which skipped the user config) and instead seeds defaults into the
  game-data dir so the saved language is read back. English by default.
- **Final controller mapping** (R36S buttons): A=Enter, B/Start=Esc, X=Space,
  Y/R1=Up, L1=Down, d-pad/stick=arrows; **L2=quick save (F1)**, **R2=quick load
  (F5)** to avoid the keyboard-only save-name prompt.
- Device-target engine built in a Debian bullseye arm64 chroot (glibc ≤ 2.30),
  linking the device's own SDL2 at runtime.

### Fixed
- Language selection reverting to English every launch.
- Quick save/load both mapped to load keys.
- Menu/back buttons not responding (invalid `escape` gptokeyb token → `esc`).

## [0.1.0] — bootstrap

### Added
- Milestone 0 repository bootstrap: full tree, scripts, docs, PortMaster skeleton.
- AGS engine pin: `3.6.2.21` (`v3.6.2.21` @ `810192970bfa8859041bca6f50ff6d9eba190036`)
  with a `3.6.2.20`/`3.6.2.19` fallback matrix.
- Three build paths sharing one version pin: Docker (`scripts/docker-build.sh`),
  direct cross-compile (`scripts/fetch-ags.sh` + `build-ags-aarch64.sh`), and
  GitHub Actions CI (`.github/workflows/build.yml`).
- `scripts/validate-game-files.sh` accepting both Windows (`TheCatLady.exe` +
  `.001/.002`) and Linux (`TheCatLady.ags`) data layouts.
- `scripts/audit-arch.sh` architecture guard; `scripts/stage-runtime.sh`;
  `scripts/make-portmaster-package.sh`; `scripts/smoke-test.sh`.
- R36S graphics/audio override config for verified 800×600→640×480 0.8× scaling.
- Provisional gptokeyb controller profile (to be finalised on device).
- PortMaster metadata (`port.json`, `gameinfo.xml`) marked `rtr:false`,
  `arch:["aarch64"]`.
- Documentation set under `docs/`.
