# Upstream engine pin

This project builds its ARM runtime from the official Adventure Game Studio engine.

- **Repository:** https://github.com/adventuregamestudio/ags
- **License:** Artistic License 2.0
- **Engine generation:** AGS 3.x (NOT AGS 4 — see spec §5)

## Pinned release (primary)

| Field         | Value                                      |
|---------------|--------------------------------------------|
| Version       | `3.6.2.21` (v3.6.2 – Patch 11)             |
| Git tag       | `v3.6.2.21`                                |
| Git commit    | `810192970bfa8859041bca6f50ff6d9eba190036` |
| Release date  | 2026-08-01                                 |
| Release type  | Stable (not a prerelease)                  |

This is the newest **stable** AGS 3.6.x release at project start. It supersedes the
`3.6.2.20` figure that appeared in the original project spec (that number was a
design-time guess; `3.6.2.21` is the verified latest stable tag).

## Compatibility matrix (spec §5)

If The Cat Lady regresses on the primary pin, fall back **in this order** and record
the result in `docs/COMPATIBILITY.md`. Do not chase `master`.

| Slot | Version    | Git tag      | Git commit                                 |
|------|------------|--------------|--------------------------------------------|
| A    | `3.6.2.21` | `v3.6.2.21`  | `810192970bfa8859041bca6f50ff6d9eba190036` |
| B    | `3.6.2.20` | `v3.6.2.20`  | `484c6329fce91a4d3d80bd303150c093315fcb24` |
| C    | `3.6.2.19` | `v3.6.2.19`  | `26f9dfc0380bf899cb69710fb9057c5c4cadccfc` |

The active pin is defined once in [`scripts/versions.env`](../scripts/versions.env);
all build scripts source it. Change the pin there, not by editing individual scripts.

## Why AGS 3.x and not AGS 4

- AGS 3.x prioritises compatibility with games compiled by older editors.
- The Cat Lady is an AGS 3-era title.
- AGS 4 intentionally drops some legacy support.

## Steam plugin note (AGSteam)

The Steam depots ship `libagsteam.so` / `agsteam.dll`, which are x86/x86_64 and cannot
be loaded by an ARM engine. AGS 3.6.x resolves unknown/absent plugins to **built-in
stubs** and supports `--no-plugins`. The port targets Strategy A (spec §6): run with
built-in stubs, Steam achievements unavailable, gameplay unaffected. See
[`docs/COMPATIBILITY.md`](../docs/COMPATIBILITY.md).
