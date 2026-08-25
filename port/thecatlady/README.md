## The Cat Lady

A native AArch64 port of *The Cat Lady* (Harvester Games) running on an
open-source Adventure Game Studio engine — no x86 emulation.

**The game is not included.** You must own a copy (Steam app 253110) and copy your
own data files onto the device. Nothing copyrighted is redistributed.

## Setup — copy your game files

Copy the data from your own copy into:

```
/roms/ports/thecatlady/gamedata/
```

AGS data is platform-independent, so Windows or Linux files both work.

**Required**
- `TheCatLady.ags` *(Linux)* **or** `TheCatLady.exe` *(Windows)*
- `audio.vox`
- `speech.vox`

**Copy if present**
- `TheCatLady.001`, `TheCatLady.002` (needed with the `.exe` — the assets are here)
- `Portuguese.tra` and/or other language `*.tra` files

**Do NOT copy**
- `ags32`, `ags64`, `lib32`, `lib64`, `agsteam.dll`, `steam_api.dll`

To find the files: in Steam, right-click The Cat Lady → **Manage → Browse local
files**. A full beginner's guide is in the repository's `INSTALL.md`.

## Controls

| Button | Action |
| --- | --- |
| D-Pad / Left Analog | Move cursor |
| A | Confirm / choose dialogue option |
| B / Start | Save & load menu |
| X | Skip dialogue |
| Y / R1 | Interact |
| L1 | Inventory |
| L2 | Quick save |
| R2 | Quick load |
| Select + Start | Quit |

The game starts in **English**; change the language in its menu and your choice is
remembered next time.

## Notes

- Runs GPU-accelerated via the engine's native OpenGL ES2 renderer on the Mali.
- Steam achievements are unavailable; gameplay is unaffected.
- Saves are under `thecatlady/saves/`; logs under `thecatlady/logs/`.

## Thanks

- **Harvester Games** — for *The Cat Lady*.
- The **Adventure Game Studio** team — for the open-source engine.
- The **PortMaster** community — for the tools and conventions that made this
  possible.
