# Steam / game files

This port needs the data files from a copy of The Cat Lady you legally own
(Steam **app 253110**). AGS data is platform-independent, so files from **either**
the Windows or the Linux build work.

## What was found on the reference machine (Windows Steam install)

Path: `...\steamapps\common\TheCatLady\`

| File | Size | Role |
|---|---:|---|
| `TheCatLady.exe` | ~54 MB | AGS engine **+ embedded main game data** (Windows) |
| `TheCatLady.001` | ~824 MB | split asset archive |
| `TheCatLady.002` | ~194 MB | split asset archive |
| `audio.vox` | ~206 MB | music / SFX |
| `speech.vox` | ~188 MB | voice acting |
| `Portuguese.tra` … `Spanish.tra` | ~0.7 MB each | translations |
| `acsetup.cfg` | 491 B | game config (native **800×600**, 32-bit) |
| `agsteam.dll`, `steam_api.dll`, `msvcr*.dll`, `d3dx*.dll` | — | **Windows-only, not used** |

There is **no** standalone `TheCatLady.ags` in the Windows build — the main data
is inside `TheCatLady.exe`. That is fine: the ARM engine reads it.

## Copy list

Copy into `/roms/ports/thecatlady/gamedata/`:

**Required**
- `TheCatLady.ags` *(Linux)* **or** `TheCatLady.exe` *(Windows)*
- `audio.vox`
- `speech.vox`

**Copy if present**
- `TheCatLady.001`, `TheCatLady.002` (needed if you copied the `.exe` — the
  assets live here)
- the translation(s) you want, e.g. `Portuguese.tra`

**Do NOT copy**
- `ags32`, `ags64`, `lib32/`, `lib64/` (Linux desktop binaries)
- `agsteam.dll` / `libagsteam.so`, `steam_api.dll`, `msvcr*.dll`, `d3dx*.dll`

## Optional: getting the clean Linux depot instead

If you prefer the tidy Linux layout (a real `TheCatLady.ags`), install the Linux
build via Steam on a Linux machine, or download depot **253112** with SteamCMD
using your own account:

```
steamcmd +login <you> +download_depot 253110 253112 +quit
```

Either layout is equally supported — this is purely cosmetic.

## Validation

`scripts/validate-game-files.sh <gamedata-dir>` checks the required files exist
and are non-empty, notes the split archives and translations, and reports which
main data file the launcher will use. Set `PRINT_SHA=1` to also print SHA-256s
for debugging (never required to launch, spec §10).
