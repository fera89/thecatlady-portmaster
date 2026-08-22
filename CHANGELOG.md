# Changelog

All notable changes to this port. Format loosely follows Keep a Changelog.

## [Unreleased]

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

### Notes
- On-device milestones (M3–M8) are pending physical R36S validation.
