# Compatibility

## Testing matrix (spec §30)

Fill in as milestones are verified. `—` = not yet tested.

Legend: ✅ pass · 🟡 pass under qemu emulation (not real hardware) · — untested.

| Test | x86_64 Linux | ARM64 build | R36S |
|---|:--:|:--:|:--:|
| AGS starts       | ✅ | 🟡 | — |
| Game detected    | ✅ | 🟡 | — |
| Main menu        | — | — | — |
| New game         | — | — | — |
| Audio (init)     | ✅ | 🟡 | — |
| Speech (detected)| ✅ | 🟡 | — |
| Video            | — | — | — |
| Input            | — | — | — |
| Portuguese       | — | — | — |
| Save             | — | — | — |
| Load             | — | — | — |
| Clean exit       | ✅ | 🟡 | — |

x86_64 and ARM64 were validated headless (dummy SDL video/audio); "Main menu"
and gameplay require a real display, i.e. the R36S. Both builds reached
"Engine initialization complete" → "Starting game" against the real Steam data.

## Environment record (fill from the device)

```
AGS version    : 3.6.2.21 (pinned)
AGS git commit : 810192970bfa8859041bca6f50ff6d9eba190036
compiler       :
optimization   : -march=armv8-a (baseline)
firmware       :
kernel         :
SDL version    :
renderer       :
audio driver   :
peak RAM       :
known issues   :
```

## Engine version decision (spec §5)

Primary pin **3.6.2.21**. If The Cat Lady regresses, test in this order and
record which one works:

| Slot | Version | Result | Notes |
|---|---|:--:|---|
| A | 3.6.2.21 | — | primary |
| B | 3.6.2.20 | — | fallback |
| C | 3.6.2.19 | — | last resort |

## AGSteam plugin (spec §6)

- **Strategy A (target):** launch with `--no-plugins`; AGS 3.6 uses built-in
  stubs. Expected result: game runs, Steam achievements unavailable. **Accepted.**
- If boot fails with an unresolved import: record the **exact** symbol name from
  `ags.log`, check AGS built-in plugin coverage, and only then consider a minimal
  no-op compatibility shim (Strategy B/C). Never copy the x86 `libagsteam.so`.
- **Result observed (2026-08-22, Milestone 2 PASS):** with `--no-plugins`,
  `agsteam` → *"Placeholder functions for the plugin 'agsteam' found"* (built-in
  stub); `agsblend` → built-in. `agsd3dvsync` has no stub and logs *"The game
  might fail to load!"*, but The Cat Lady does not import it, so boot proceeds to
  "Starting game" normally. Strategy A works; no shim needed.

## Video (spec §7)

Video support is compiled **in**. Determine at test time whether The Cat Lady
plays any video and in what format; if a clip is skipped, log the filename and
codec. Do not disable the video player unless testing proves it unnecessary.

## Notes on scaling

Native 800×600 (4:3) → 640×480 (4:3) is a uniform 0.8× downscale: full screen,
correct aspect, no bars. `filter=linear` is used because 0.8× is non-integer.
