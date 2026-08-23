# The Cat Lady (R36S)

Native AArch64 port of *The Cat Lady* running on an open-source Adventure Game
Studio engine. **The game itself is not included** — you must own a copy and copy
your own data files onto the device.

## Installing the game files

This port does not include The Cat Lady. You need an original copy
(Steam app 253110). The game data is the same on Windows and Linux, so files from
either version work.

Copy these into:

```
/roms/ports/thecatlady/gamedata/
```

**Required**
- `TheCatLady.ags` *(Linux version)* **or** `TheCatLady.exe` *(Windows version)*
- `audio.vox`
- `speech.vox`

**Copy if present**
- `TheCatLady.001`, `TheCatLady.002`  (the assets — needed with the `.exe`)
- `Portuguese.tra` and/or other language `*.tra` files

**Do NOT copy**
- `ags32`, `ags64`, `lib32`, `lib64`
- `agsteam.dll` / `libagsteam.so`, `steam_api.dll`

To find the files: in Steam, right-click The Cat Lady → **Manage → Browse local
files**.

The port uses its own ARM build of Adventure Game Studio, so the copyrighted game
files are never redistributed and remain yours.

## Playing

Launch **The Cat Lady** from the Ports menu. The game is played entirely with
these R36S buttons:

| R36S button | What it does |
|---|---|
| **D-pad / Left stick ← →** | Move (walk between scenes) |
| **D-pad / Left stick ↑** (or **Y**, **R1**) | Interact with objects |
| **D-pad / Left stick ↓** (or **L1**) | Open inventory |
| **A** | Confirm / choose dialogue option |
| **X** | Skip dialogue |
| **B** or **Start** | Save / load menu |
| **Select + Start** (hold) | Quit back to PortMaster |

## Notes

- Steam achievements are unavailable on this port; gameplay is unaffected.
- Saves are stored under `thecatlady/saves/` inside the port folder.
- Logs are in `thecatlady/logs/` if you need to report a problem.
