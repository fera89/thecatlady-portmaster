# STATUS

Progress report in the spec §36 format. Updated 2026-08-21.

Development environment for this pass: **Windows 11** with git + Git-Bash only —
**no WSL, no Docker, no local Linux toolchain, no physical R36S**. Everything that
requires compiling ARM code or running on the device is therefore scripted and
verified-by-design, to be executed by the user via Docker/CI/device.

---

## DONE

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

## BLOCKED (need something not present in this environment)

- **Actually compiling the ARM binary here.** No WSL/Docker/cmake on this
  Windows host. → Resolved by design: run `./scripts/docker-build.sh` (needs
  Docker Desktop) **or** push to GitHub for the CI build. No code change needed.
- **Milestone 1 (desktop x86_64 Linux validation).** Needs a Linux/WSL2 box or
  CI. The headless [smoke-test.sh](scripts/smoke-test.sh) automates it once a
  build exists.

## NEEDS DEVICE TEST (physical R36S required)

- **M3** ARM engine runs on device · **M4** AGS smoke test · **M5** The Cat Lady
  boots to menu · **M6** controller mapping finalised · **M7** gameplay systems
  (rooms/dialog/inventory/speech/music/SFX/save/load/Portuguese/exit) ·
  **M8** endurance · sprite-cache tuning after measuring `VmRSS`/`VmHWM` (spec §22).
- Record results in [docs/COMPATIBILITY.md](docs/COMPATIBILITY.md) and save at
  least one real device log (spec §27).

## NEXT (recommended order)

1. **Build the engine** — install Docker Desktop and run
   `./scripts/docker-build.sh`, *or* push this repo to GitHub and download the CI
   artifact.
2. **Milestone 1** — run `scripts/smoke-test.sh --ags <built-ags> --gamedata
   <your-gamedata>` to confirm the modern engine loads The Cat Lady headlessly
   and that AGSteam is handled by built-in stubs.
3. **Package** — `./scripts/make-portmaster-package.sh` → `dist/*.zip`.
4. **On device** — deploy, copy game data, and work Milestones 5–8, filling in
   the compatibility matrix and controls doc.
