# runtime/

Source assets that `scripts/stage-runtime.sh` copies into the installed port.

- `config/acsetup-r36s.cfg` — R36S graphics/audio override, passed to the engine
  with `--conf` (staged as `thecatlady/config/acsetup.cfg`). Tuned for the game's
  verified 800×600 native resolution downscaled to 640×480 (0.8×, 4:3, no bars).
- `controls/thecatlady.gptk` — provisional gptokeyb mapping (staged to the port
  root). Finalise on device; see `docs/CONTROLS.md`.

These are edited here in source control, never edited in the staged port
directory (staging overwrites them).
