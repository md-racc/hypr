# Hyprland Keybind Reference

> Search tip: use `/pattern` in your pager, or `grep -i keyword KEYBINDS.md`
> Live truth: `hyprctl binds -j | jq` · shared binds in `conf/keybinds.lua`, machine extras in `conf/machine/keybinds.lua`

---

## Table of Contents

- [Apps & Launchers](#apps--launchers)
- [Machine-Specific Apps](#machine-specific-apps)
- [Window Management](#window-management)
- [Focus & Moving Windows](#focus--moving-windows)
- [Resize — hold `SUPER+W`](#resize--hold-superw)
- [Workspaces](#workspaces)
- [Special Workspace (Scratchpad)](#special-workspace-scratchpad)
- [Mouse](#mouse)
- [Screenshots](#screenshots)
- [Power — `SUPER+X`](#power--superx)
- [Session](#session)
- [Volume & Media](#volume--media)
- [Brightness](#brightness)

---

## Apps & Launchers

| Key | Action |
|-----|--------|
| `SUPER+Return` | Terminal (`kitty` + zsh) |
| `SUPER+B` | Browser (`firefox`) |
| `SUPER+R` | App launcher (`fuzzel`) |
| `SUPER+V` | Clipboard history picker (`cliphist` → fuzzel → paste-ready) |
| `SUPER+SHIFT+V` | Vaultwarden picker (`~/.local/bin/vw`: rbw → fuzzel, fingerprint unlock) |
| `SUPER+Tab` | Window switcher (fuzzel list of open windows) |

---

## Machine-Specific Apps

Same keys, per-machine meaning. Defined in `conf/machine/keybinds.lua`.

| Key | zion (desktop) | rocinante (ThinkPad) |
|-----|----------------|----------------------|
| `SUPER+E` | File manager (`kitty ranger`) | same |
| `SUPER+P` | Task manager (`kitty btop`) | same |
| `SUPER+T` | Editor (`kitty nvim`) | same |
| `SUPER+O` | Notes (`obsidian`) | same |
| `SUPER+C` | Calculator (`qalculate-gtk`) | Network menu (`netmenu`) |
| `SUPER+Z` | — | Toggle eww bar |
| `ALT+BrightnessUp/Down` | — | Keyboard backlight ±1 |

---

## Window Management

| Key | Action |
|-----|--------|
| `SUPER+Q` | Close window |
| `SUPER+F` | Fullscreen (maximize style, keeps bars) |
| `SUPER+Space` | Toggle floating |
| `SUPER+SHIFT+Space` | Cycle focus tiled → each floating window → back to tiled (wraps if only floating windows exist) |
| `SUPER+S` | Toggle split axis (side-by-side ↔ stacked) |
| `SUPER+SHIFT+S` | Rotate split 90° (windows carried around the rotation) |
| `SUPER+SHIFT+E` | Reset all splits on workspace to even (dwindle-calculated sizes) |
| `SUPER+SHIFT+C` | Reload Hyprland config |

`SUPER+S` flips the axis but keeps window order; `SUPER+SHIFT+S` moves the
windows *through* the rotation. Both require `dwindle:preserve_split`.

---

## Focus & Moving Windows

Vim keys. Plain = focus, SHIFT = move window.

| Key | Action |
|-----|--------|
| `SUPER+H/J/K/L` | Focus left / down / up / right |
| `SUPER+SHIFT+H/J/K/L` | Move window left / down / up / right (H/L cross to adjacent workspace at edge) |

---

## Resize — hold `SUPER+W`

Hold-style submap: **keep holding SUPER+W**, mash HJKL (they repeat while
held), releasing `W` exits. 40px steps.

| Key (while held) | Action |
|-----|--------|
| `H` | Shrink width (grow left edge) |
| `J` | Grow height (down) |
| `K` | Shrink height (up) |
| `L` | Grow width (right) |
| release `W` / `Esc` / any other key | Exit resize |

Mouse alternative: `SUPER+RightMouse` drag (see [Mouse](#mouse)).

---

## Workspaces

| Key | Action |
|-----|--------|
| `SUPER+1…9,0` | Go to workspace 1–10 |
| `SUPER+SHIFT+1…9,0` | Move window to workspace 1–10 |
| `SUPER+CTRL+1…9,0` | **Send all** windows on current workspace to target, follow |
| `SUPER+ScrollDown` | Next workspace |
| `SUPER+ScrollUp` | Previous workspace |

---

## Special Workspace (Scratchpad)

| Key | Action |
|-----|--------|
| `` SUPER+` `` | Toggle special workspace overlay |
| `` SUPER+SHIFT+` `` | Move window to special workspace |

Windows with class `scratchpad` float 900x600 centered there automatically
(`rules.lua`).

---

## Mouse

| Key | Action |
|-----|--------|
| `SUPER+LeftMouse` drag | Move window |
| `SUPER+RightMouse` drag | Resize window |
| `SUPER+Scroll` | Cycle workspaces |

`resize_on_border` is on — bare drag on a window border also resizes.

---

## Screenshots

[`screenie`](https://gitea.lan/mdracc/screenie): the Rust port, installed
to `~/.cargo/bin` (`cargo install --path crates/screenie` from its `rust/`). Area shots open its picker: every monitor
freezes and a box starts on the active window; drive it like vim
visual-block mode or with the mouse, then `Enter`. The picker's keys (and
its loupe, enhance, censor, OCR, colour, QR and pin tools) are documented in
[screenie's README](https://gitea.lan/mdracc/screenie#the-picker).

| Key | Action |
|-----|--------|
| `Print` | Area → clipboard |
| `SHIFT+Print` | Active window → clipboard |
| `SUPER+Print` | Area → clipboard + file (`~/documents/pictures/screenshots/`) |
| `SUPER+SHIFT+Print` | Active window → clipboard + file |
| `SUPER+N` | Annotate the last screenshot (`screenie edit last --mode annotate`) |
| `SUPER+G` | OCR the most recent image (`screenie edit --result text`), copy extracted text |

Every screenshot is kept in `$XDG_RUNTIME_DIR/screenie/` with its
project (clipboard-only shots too), so `SUPER+N` reopens the most recent
shot of either kind in screenie's picker, in Annotate, with its earlier
censors and annotations still editable; every other tool (censor,
filter, OCR, pin…) is there too. `Enter` copies the result. Does nothing
until a screenshot has been taken this login.

`SUPER+G` replaces [`textgrab`](https://gitea.lan/mdracc/textgrab): it
opens the most recent image in screenie's picker, the image on the
clipboard (from screenie or any other app; a screenie shot reopens with
its layers) or, with none there, the last screenshot. The box starts on
the whole image; drag a region to narrow it, then `Enter` OCRs it,
copies the text and shows a preview in a notification. Inside the
picker of a fresh shot, `y` OCRs the box directly.

---

## Power — `SUPER+X`

Tap `SUPER+X`, **keep SUPER held**, then one key.

| Key | Action |
|-----|--------|
| `SUPER+L` | Lock (`loginctl lock-session` → `scripts/lockscreen`) |
| `SUPER+A` | **Away mode** — lock + screens off; suspend *and lid-close* blocked, processes/network stay alive until unlock |
| `SUPER+S` | Suspend |
| `SUPER+R` | Reboot |
| `SUPER+P` | Power off |
| `SUPER+O` | Exit Hyprland session (clean, via `session-exit`) |
| `Esc` / any other key | Exit submap |

### From the lock screen

Submaps can't be entered while locked. Use these direct binds instead.
The F-keys work like ly's and exist only while locked. A press that wakes
dark displays only wakes them. On rocinante they're the media keys unless
Fn-lock is on (or hold Fn).

| Key | Action |
|-----|--------|
| `F1` | Power off |
| `F2` | Reboot |
| `F3` | Suspend (ends away mode first) |
| `F4` | Away mode (as `SUPER+X` → `SUPER+A`; already locked, so it just blocks suspend/lid and turns the screens off) |

---

## Session

| Key | Action |
|-----|--------|
| `SUPER+SHIFT+C` | Reload config (`hyprctl reload`) |

---

## Volume & Media

Volume repeats while held and works on the lock screen.

| Key | Action |
|-----|--------|
| `VolumeUp/Down` | Volume ±5% |
| `Mute` | Toggle mute |
| `MicMute` | Toggle mic mute |
| `MediaPlay/Pause` | Play/pause (`playerctl`) |
| `MediaNext/Prev` | Next / previous track (`playerctl`) |

---

## Brightness

Works on the lock screen.

| Key | Action |
|-----|--------|
| `BrightnessUp/Down` | Backlight ±10% |
| `SUPER+BrightnessUp/Down` | Fine step ±5% |
| `ALT+BrightnessUp/Down` | Keyboard backlight (rocinante only) |
