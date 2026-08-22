# Architecture

```
        Your legally-owned copy of The Cat Lady
                       │  copy game DATA only (never binaries)
                       ▼
        /roms/ports/thecatlady/gamedata/
          TheCatLady.ags  (or TheCatLady.exe)
          TheCatLady.001 / .002   audio.vox   speech.vox   *.tra
                       │
                       ▼
              AGS 3.6.2.21 runtime  (native AArch64, our build)
                       │
        ┌──────────────┼───────────────┐
        ▼              ▼               ▼
      SDL2          Audio          AGS scripts
        │
        ▼
   Linux / ArkOS  ──  gptokeyb (gamepad → mouse/keyboard)
        │
        ▼
   RK3326 / R36S  →  640×480 (game renders 800×600, scaled 0.8×)
```

## Principles

- **Native ARM only.** Engine is compiled for `aarch64`; a mandatory audit
  (spec §14) rejects any x86/x86_64 binary. No Box86/Box64, no `ags32`/`ags64`.
- **Data, not binaries.** Only the game's data files are copied from the user's
  copy. The Steam desktop executables and the x86 `libagsteam.so`/`agsteam.dll`
  are intentionally outside the execution path (spec §6).
- **Config isolation.** The R36S override `acsetup.cfg` is passed with `--conf`;
  the user's original config is never modified (spec §16).
- **Save isolation.** `XDG_DATA_HOME` is redirected into the port dir so saves
  live under `thecatlady/saves/` and the game-data dir stays read-only (spec §17).

## Why the Windows data works

AGS compiles a game into a platform-independent data package. The engine binary
differs per platform, but `TheCatLady.ags`/`.exe`, `audio.vox`, `speech.vox` and
`*.tra` are identical bytes across Windows/Linux. Our ARM engine reads the same
data. When only `TheCatLady.exe` is present, the engine loads the game data that
is appended to that executable; it does **not** execute Windows code.

## Plugin strategy (AGSteam)

The game references the Steam plugin. We launch with `--no-plugins`; AGS 3.6
resolves the reference to a built-in stub, so the game runs with Steam
achievements unavailable — an accepted outcome (spec §6). If a specific import
proves fatal, Milestone 2 narrows it to the exact symbol before doing more.

## Runtime library policy

Prefer static linkage where the pinned AGS build allows it. Otherwise the arm64
`.so` files (SDL2, ogg, vorbis, theora) are bundled in `thecatlady/lib/` and
found via `LD_LIBRARY_PATH`. Every bundled library is recorded and audited.
