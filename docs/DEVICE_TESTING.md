# Device testing (R36S)

Steps that require the physical handheld. Do not claim success for any of these
without a real device log (spec §35).

## 0. Record the environment first (spec §2)

SSH into the device (ArkOS enables SSH; default is usually `ark` / `ark`) and run:

```bash
uname -a
uname -m
getconf LONG_BIT
ldd --version
cat /etc/os-release
```

Paste the output into `docs/COMPATIBILITY.md`. **If `uname -m` is not `aarch64`**
(i.e. the firmware runs a 32-bit userspace), stop and revisit the arch policy —
an `armhf` build would then be needed (spec §2).

## 1. Install the port

Option A — PortMaster: copy `dist/thecatlady-r36s-*.zip` to the device and
install it from PortMaster's "install from file" flow.

Option B — manual:
```bash
cd /roms/ports
unzip /path/to/thecatlady-r36s-*.zip
```

You should now have `/roms/ports/The Cat Lady.sh` and `/roms/ports/thecatlady/`.

## 2. Copy your game data

```bash
mkdir -p /roms/ports/thecatlady/gamedata
# copy TheCatLady.ags (or .exe) + .001/.002 + audio.vox + speech.vox + *.tra here
/roms/ports/thecatlady/bin/validate-game-files /roms/ports/thecatlady/gamedata
```

## 3. First boot (Milestone 5)

Launch **The Cat Lady** from the Ports menu, or from a shell:
```bash
"/roms/ports/The Cat Lady.sh"
```
Then inspect:
```bash
tail -n 100 /roms/ports/thecatlady/logs/launcher.log
tail -n 100 /roms/ports/thecatlady/logs/ags.log
```

Record: boot time, renderer actually used, SDL video/audio driver, any plugin
warnings, and peak memory:
```bash
free -m
grep -E 'VmRSS|VmHWM' /proc/$(pgrep -n ags)/status
```

## 4. Graphics fallback order (spec §15)

If the screen is black or scaled wrong, edit
`/roms/ports/thecatlady/config/acsetup.cfg`:

1. `driver=Software` (default) — try first.
2. If software is wrong/slow, set `driver=OGL`.
3. Confirm `game_scale_fs=proportional` (keeps 4:3; fills 640×480 exactly).

## 5. Audio (spec §21)

Default SDL backend first. If silent:
```bash
SDL_AUDIODRIVER=alsa "/roms/ports/The Cat Lady.sh"
```
Check music, SFX, and `speech.vox` voice lines.

## 6. Controls (Milestone 6)

Verify every required action is reachable from the pad using
`runtime/controls/thecatlady.gptk`. Finalise the real mapping in
[CONTROLS.md](CONTROLS.md).

## 7. Gameplay + endurance (Milestones 7–8)

Rooms, dialog, inventory, speech, music, SFX, menus, **save**, **load**,
**Portuguese** translation, and clean exit to the frontend. Then a long session
watching for memory growth, audio degradation, input loss and save corruption.
Fill in [COMPATIBILITY.md](COMPATIBILITY.md) and commit at least one device log.

## Debugging quick refs

- Crash on room change → `dmesg | tail` (look for OOM); lower `cachemax`.
- Save failure → check `XDG_DATA_HOME` dir perms and free space.
- Plugin/import error → see [COMPATIBILITY.md](COMPATIBILITY.md) AGSteam section.
