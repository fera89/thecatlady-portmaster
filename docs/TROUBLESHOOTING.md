# Troubleshooting

Decision tree adapted from spec §29. Logs live in
`/roms/ports/thecatlady/logs/` (`launcher.log`, `ags.log`).

## Game does not start

```bash
file /roms/ports/thecatlady/bin/ags        # must say ARM aarch64
ldd  /roms/ports/thecatlady/bin/ags        # any "not found" => stage that lib
```
Then check, in order: `ags.log`, `launcher.log`, missing shared libs, wrong
architecture, game-data path, file permissions.

## "Game data not found"

Run the validator and follow its message:
```bash
/roms/ports/thecatlady/bin/validate-game-files /roms/ports/thecatlady/gamedata
```
Most common cause: only `TheCatLady.exe` was copied but **not** its
`TheCatLady.001` / `.002` split archives (the assets live there).

## Error mentions a plugin / import

The Steam plugin is expected to be absent. The launcher already passes
`--no-plugins`. If `ags.log` shows an **unresolved import**:

1. copy the exact symbol name from the log,
2. check whether AGS has a built-in stub for it,
3. only then consider a minimal no-op shim (spec §6, Strategy B/C).

Never copy the x86 `libagsteam.so` / `agsteam.dll`.

## Black screen

Check SDL video driver and try renderers in this order (edit
`config/acsetup.cfg`): `driver=Software` → `driver=OGL`. Confirm
`game_scale_fs=proportional`. Try `SDL_VIDEODRIVER=kmsdrm` if the frontend uses
it.

## No audio

```bash
SDL_AUDIODRIVER=alsa "/roms/ports/The Cat Lady.sh"
```
Verify `audio.vox` and `speech.vox` are present and non-empty. Try SDL default
first, then ALSA (spec §21). Do not force PulseAudio if the firmware lacks it.

## Crash when changing rooms

Usually memory. Check:
```bash
dmesg | tail                                  # look for OOM killer
grep -E 'VmRSS|VmHWM' /proc/$(pgrep -n ags)/status
```
Lower `cachemax` in `config/acsetup.cfg` conservatively (spec §22) and re-test.

## Save failure

Check `XDG_DATA_HOME` (`/roms/ports/thecatlady/saves`) exists and is writable,
directory ownership, and free disk space. Saves should appear under
`saves/ags/<game>/`.

## Controls wrong / can't do something

Edit `runtime/controls/thecatlady.gptk` (staged to the port root as
`thecatlady.gptk`) and see [CONTROLS.md](CONTROLS.md). The mapping is provisional
until verified on device.
