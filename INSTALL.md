# Installing The Cat Lady on your R36S — beginner's guide

A step-by-step for someone who has **The Cat Lady on Steam (PC)** and an **R36S**
and has never done this before. It assumes your R36S runs **ArkOS** with
**PortMaster** (that's the default on most R36S units).

> This port does **not** include the game. You copy the data from your own Steam
> copy — nothing copyrighted is redistributed.

---

## What you'll need
- A **microSD card reader** on your PC (or an adapter).
- **The Cat Lady installed on Steam** on your PC.
- A few minutes — the game files are ~1.4 GB, so copying takes a while.

---

## Part 1 — Download the port (on your PC)

1. Open **https://github.com/fera89/thecatlady-portmaster/releases/latest**
2. Under **Assets**, click **`thecatlady-portmaster.zip`** to download it.

## Part 2 — Move the R36S card to your PC

3. **Turn off** the R36S.
4. Take out the **games card** (the bottom slot — it shows up as **EASYROMS** on
   the PC) and put it in your PC's card reader.

## Part 3 — Copy the port onto the card

5. Open the `thecatlady-portmaster.zip` you downloaded. Inside you'll see:
   - a file **`The Cat Lady.sh`**
   - a folder **`thecatlady`**
6. Copy **both** into the **`ports`** folder on the card. It should look like:
   ```
   (card)\ports\The Cat Lady.sh
   (card)\ports\thecatlady\
   ```
   > If there's no `ports` folder, create one.

## Part 4 — Find the game files on Steam

7. Open **Steam** on your PC.
8. **Right-click** *The Cat Lady* → **Manage** → **Browse local files**. The game's
   folder opens.

## Part 5 — Copy the game files onto the card

9. From that Steam folder, copy **these files**:
   - `TheCatLady.exe`
   - `TheCatLady.001` and `TheCatLady.002`
   - `audio.vox`
   - `speech.vox`
   - *(optional)* `Portuguese.tra` and any other `.tra` language files you want
10. Paste them into:
    ```
    (card)\ports\thecatlady\gamedata\
    ```
    > That folder already has a `PUT_STEAM_FILES_HERE.txt` file — it's just a
    > "put them here" marker. Leave it there.

    ❌ **Don't** copy: `ags32`, `ags64`, `lib32`, `lib64`, `agsteam.dll`,
    `steam_api.dll`.

> **On the Linux version of the game?** Then copy `TheCatLady.ags` instead of the
> `.exe`/`.001`/`.002`, plus `audio.vox` and `speech.vox`. Either version works.

## Part 6 — Back into the R36S and play

11. **Safely eject** the card on the PC, put it back in the R36S, and **turn it on**.
12. In the menu, go to **Ports** (or **PortMaster → Ports**) → **The Cat Lady**.
13. 🎉 That's it — the game starts!

---

## Controls on the R36S

| Button | Action |
|---|---|
| D-pad / Left stick | Move |
| **A** | Confirm |
| **X** | Skip dialogue |
| **B** or **Start** | Menu / save |
| **L2** / **R2** | Quick save / Quick load |
| **Select + Start** | Quit |

The game starts in **English**; you can change the language in the game's own menu
and your choice is **remembered** next time.

## If something goes wrong
- **Black screen:** almost always a missing file — check that `TheCatLady.exe`,
  `.001`, `.002`, `audio.vox` and `speech.vox` are all in `gamedata`.
- **It doesn't show up under Ports:** make sure `The Cat Lady.sh` is **directly**
  inside `ports\` (not inside another subfolder).
- Logs for troubleshooting are written to `ports\thecatlady\logs\`.
