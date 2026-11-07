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
- [Screen Recording](#screen-recording)
- [Macros — `again` (zion)](#macros--again-zion)
- [Power — `SUPER+X`](#power--superx)
- [Session](#session)
- [Volume & Media](#volume--media)
- [Brightness](#brightness)
- [Notifications](#notifications)

---

## Apps & Launchers

| Key | Action |
|-----|--------|
| `SUPER+Return` | Terminal (`kitty` + zsh) |
| `SUPER+B` | Browser (`firefox`) |
| `SUPER+R` | App launcher (`fuzzel`) |
| `SUPER+V` | Clipboard history picker (`scripts/clip-pick`: cliphist → fuzzel → paste-ready). Images show a thumbnail. In the picker: `Shift+Delete` deletes the entry and reopens, `Ctrl+Shift+Delete` wipes the history (asks first). History is capped at 300 entries |
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
| `SUPER+C` | — | Network menu (`netmenu`) |
| `SUPER+Z` | — | Toggle eww bar |
| `ALT+BrightnessUp/Down` | — | Keyboard backlight ±1 |

---

## Window Management

| Key | Action |
|-----|--------|
| `SUPER+Q` | Close window |
| `SUPER+F` | Fullscreen (maximize style, keeps bars) |
| `SUPER+Space` | Cycle focus tiled → each floating window → back to tiled (wraps if only floating windows exist) |
| `SUPER+SHIFT+Space` | Toggle floating |
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
| `` SUPER+` `` | Drop-down terminal: show/hide the special workspace; starts the scratchpad terminal first if it isn't running (`scripts/scratchpad`) |
| `` SUPER+SHIFT+` `` | Move window to special workspace |

The scratchpad terminal is kitty with class `scratchpad` attached to tmux's
`scratch` session (the same as tmux `prefix t`, so its shell survives
toggles). Windows with that class float 900x600 centered on the special
workspace automatically (`rules.lua`).

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
| `SUPER+G` | Open the last screenshot (`screenie edit last`) with all editor tools available |
| `SUPER+SHIFT+G` | Annotate the last screenshot (`screenie edit last --mode annotate`) |

Every screenshot is kept in `$XDG_RUNTIME_DIR/screenie/` with its
project (clipboard-only shots too), so `SUPER+SHIFT+G` reopens the most recent
shot of either kind in screenie's picker, in Annotate, with its earlier
censors and annotations still editable; every other tool (censor,
filter, OCR, pin…) is there too. `Enter` copies the result. Does nothing
until a screenshot has been taken this login.

`SUPER+G` opens the last screenshot in screenie's picker with its layers
still editable. All tools are available, including annotate, censor,
filter, OCR and pin. Inside the picker, `y` OCRs the box directly.

---

## Screen Recording

`scripts/record` drives [gpu-screen-recorder](https://git.dec05eba.com/gpu-screen-recorder/about/)
(H.264 on the GPU: NVENC on zion, VA-API on rocinante, CPU if neither works).
Files land in `~/documents/videos/`; when one is saved, a notification shows
the path and a `file://` URI is copied. Any toggle key stops a running
recording. `record --help` for the rest (`-a` adds desktop audio).

| Key | Action |
|-----|--------|
| `SUPER+ALT+Print` | Record an area (screenie's picker, `Enter` starts) / stop |
| `SUPER+ALT+SHIFT+Print` | Record the active window's box / stop |
| `SUPER+CTRL+Print` | Record the focused monitor / stop |
| `SUPER+CTRL+SHIFT+Print` | Replay buffer: first press starts it (last 30 s of the focused monitor, desktop audio, in RAM); each later press saves those 30 s |
| `SUPER+CTRL+ALT+Print` | Replay buffer off (nothing saved) |

---

## Macros — `again` (zion)

[`again`](https://gitea.lan/mdracc/again) records and replays keyboard input (evdev → uinput),
installed to `~/.local/bin`. Defined in `conf/machine/keybinds.lua`. Keyboards are autodetected;
needs the device permissions from again's `docs/permissions.md`.

| Key | Action |
|-----|--------|
| `SUPER+SHIFT+.` | Start recording; press again to stop and keep it as the latest macro |
| `SUPER+.` | Play the latest macro once, idle pauses at 2x and capped at 1 s (waits until you release the keys) |
| `SUPER+Escape` | Cancel recording or playback (releases any keys it holds) |

Pressing any key during playback also aborts it. Key holds replay exactly; only idle pauses are
paced. Notifications come from `~/.config/again/hook`; `again status` shows progress.
---

## Power — `SUPER+X`

Tap `SUPER+X`, **keep SUPER held**, then one key.

| Key | Action |
|-----|--------|
| `SUPER+L` | Lock (`loginctl lock-session` → `scripts/lockscreen`) |
| `SUPER+A` | **Away mode** — lock + screens off (not on zion: NVIDIA crash, screens stay on); suspend *and lid-close* blocked, processes/network stay alive until unlock |
| `SUPER+S` | Suspend |
| `SUPER+R` | Reboot |
| `SUPER+P` | Power off |
| `SUPER+O` | Exit Hyprland session (clean, via `session-exit`) |
| `Esc` / any other key | Exit submap |

### From the lock screen

Submaps can't be entered while locked. Use these direct binds instead.
The F-keys work like ly's and exist only while locked. A press that wakes
dark displays only wakes them (on zion that includes screens the idle
timer switched off over DDC). On rocinante they're the media keys unless
Fn-lock is on (or hold Fn).

| Key | Action |
|-----|--------|
| `F1` | Power off |
| `F2` | Reboot |
| `F3` | Suspend (ends away mode first) |
| `F4` | Away mode (as `SUPER+X` → `SUPER+A`; already locked, so it just blocks suspend/lid and turns the screens off, except on zion) |

---

## Session

| Key | Action |
|-----|--------|
| `SUPER+SHIFT+C` | Reload config (`hyprctl reload`) |

---

## Volume & Media

Volume repeats while held, stops at 100%, and works on the lock screen. Each
press shows the level in one bubble that updates in place (`scripts/osd`).

| Key | Action |
|-----|--------|
| `VolumeUp/Down` | Volume ±5% (max 100%) |
| `Mute` | Toggle mute (no repeat) |
| `MicMute` | Toggle mic mute (no repeat) |
| `MediaPlay/Pause` | Play/pause (`playerctl`) |
| `MediaNext/Prev` | Next / previous track (`playerctl`) |

---

## Brightness

Works on the lock screen and shows the level (`scripts/osd`). Laptops step the
backlight; zion (no backlight) steps both monitors over DDC/CI
(`scripts/ddc-brightness`).

| Key | Action |
|-----|--------|
| `BrightnessUp/Down` | Brightness ±10% |
| `SUPER+BrightnessUp/Down` | Fine step ±5% |
| `SUPER+F6` / `SUPER+F5` | Monitors ±10% over DDC/CI (zion only; same keys as ly) |
| `ALT+BrightnessUp/Down` | Keyboard backlight (rocinante only) |

---

## Notifications

| Key | Action |
|-----|--------|
| `SUPER+N` | Dismiss the newest notification (`fnottctl dismiss`) |
| `SUPER+SHIFT+N` | Pick an action of a notification (fuzzel; `fnottctl actions`) |
| `SUPER+CTRL+N` | Do not disturb on/off (`scripts/dnd`): new notifications are held and all shown when it's turned off — critical ones too |
