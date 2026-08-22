# Controls

> **Status: PROVISIONAL.** The Cat Lady's exact default keys must be confirmed by
> on-device testing (Milestone 6) before this table is treated as final. Per spec
> §19, nothing here is asserted from memory as the game's real binding.

The gamepad is translated to mouse + keyboard by **gptokeyb** (provided by
PortMaster on-device). The profile is
[`runtime/controls/thecatlady.gptk`](../runtime/controls/thecatlady.gptk).

## Provisional mapping

| Control | Sends | Purpose (to verify) |
|---|---|---|
| Left stick | mouse move | move the cursor |
| A | left click | walk / primary interact |
| B | right click | examine / change verb |
| D-pad | arrow keys | menu navigation / keyboard movement |
| X | `i` | inventory (guess) |
| Y | `space` | continue / skip dialog (guess) |
| Start | `enter` | confirm / advance |
| Select | `esc` | menu / cancel |
| L1 / R1 | pageup / pagedown | convenience |
| L2 / R2 | left / right click | alt mouse buttons |
| Select + Start (hold) | quit | return to PortMaster |

## How to finalise (on device)

1. Boot the game and open its own controls/help screen if it has one.
2. Confirm what actually moves the character and interacts (mouse vs arrows).
3. Confirm the inventory and skip/continue keys.
4. Edit `thecatlady.gptk`, re-test, then update this table and remove the
   "provisional" banner.

## Design goals (spec §19)

Fully playable with **no external keyboard or mouse**: movement, interaction,
inventory, dialog advance, menu, save/load, and quit must all be reachable from
the built-in controls.
