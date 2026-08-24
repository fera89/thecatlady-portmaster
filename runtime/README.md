# runtime/

Source assets that `scripts/stage-runtime.sh` copies into the installed port.

- `config/acsetup-r36s.cfg` — R36S graphics/audio defaults (staged as
  `thecatlady/config/acsetup.cfg`). Tuned for the game's verified 800×600 native
  resolution downscaled to 640×480 (0.8×, 4:3, no bars). The launcher seeds this
  into `gamedata/acsetup.cfg` (the engine's StartupDir config) at boot; it is
  **not** passed with `--conf`, because `--conf` makes AGS skip the user config
  where the player's language choice is persisted.
- `controls/thecatlady.gptk` — gptokeyb mapping (staged to the port root).
  Final R36S mapping; see `docs/CONTROLS.md`.

These are edited here in source control, never edited in the staged port
directory (staging overwrites them).
