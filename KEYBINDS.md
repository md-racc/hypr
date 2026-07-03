# Hyprland Keybind Reference

> Search tip: use `/pattern` in your pager, or `grep -i keyword KEYBINDS.md`
> Live truth: `hyprctl binds -j | jq` · shared binds in `conf/keybinds.conf`, machine extras in `conf/machine/keybinds.conf`

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
- [Notifications — `SUPER+N`](#notifications--supern)
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
| `SUPER+Tab` | Window switcher (fuzzel list of open windows) |

---

## Machine-Specific Apps

Same keys, per-machine meaning. Defined in `conf/machine/keybinds.conf`.

| Key | zion (desktop) | rocinante (ThinkPad) |
|-----|----------------|----------------------|
| `SUPER+E` | File manager (`kitty ranger`) | same |
| `SUPER+P` | Task manager (`kitty btop`) | same |
| `SUPER+T` | Editor (`kitty nvim`) | same |
| `SUPER+O` | Notes (`obsidian`) | same |
| `SUPER+C` | Calculator (`qalculate-gtk`) | Network menu (`netmenu`) |
| `SUPER+Z` | — | Toggle eww bar |
| `SUPER+SHIFT+E` | Reset splits (**broken**, fix pending) | — |
| `ALT+BrightnessUp/Down` | — | Keyboard backlight ±1 |

---

## Window Management

| Key | Action |
|-----|--------|
| `SUPER+Q` | Close window |
| `SUPER+F` | Fullscreen (maximize style, keeps bars) |
| `SUPER+Space` | Toggle floating |
| `SUPER+S` | Toggle split axis (side-by-side ↔ stacked) |
| `SUPER+SHIFT+S` | Rotate split 90° (windows carried around the rotation) |
| `SUPER+SHIFT+C` | Reload Hyprland config |

`SUPER+S` flips the axis but keeps window order; `SUPER+SHIFT+S` moves the
windows *through* the rotation. Both require `dwindle:preserve_split`.

---

## Focus & Moving Windows

Vim keys. Plain = focus, SHIFT = move window.

| Key | Action |
|-----|--------|
| `SUPER+H/J/K/L` | Focus left / down / up / right |
| `SUPER+SHIFT+H/J/K/L` | Move window left / down / up / right |

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
(`rules.conf`).

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

grimblast under the hood; area mode = drag-select a region.

| Key | Action |
|-----|--------|
| `Print` | Area → clipboard |
| `SHIFT+Print` | Active window → clipboard |
| `SUPER+Print` | Area → file (`~/documents/pictures/screenshots/`) |
| `SUPER+SHIFT+Print` | Active window → file |

File mode remembers the last shot for `SUPER+N A` annotation.

---

## Notifications — `SUPER+N`

Tap `SUPER+N`, then one key (submap exits after each action).

| Key | Action |
|-----|--------|
| `A` | Annotate last screenshot in `satty` |
| `D` | Dismiss newest notification |
| `SHIFT+D` | Dismiss all notifications |
| `Esc` / any other key | Exit |

---

## Power — `SUPER+X`

Tap `SUPER+X`, **keep SUPER held**, then one key.

| Key | Action |
|-----|--------|
| `SUPER+L` | Lock (`hyprlock` with blurred screenshot) |
| `SUPER+S` | Suspend |
| `SUPER+R` | Reboot |
| `SUPER+P` | Power off |
| `SUPER+O` | Exit Hyprland session (clean, via `session-exit`) |
| `Esc` / any other key | Exit submap |

---

## Session

| Key | Action |
|-----|--------|
| `SUPER+M` | Exit Hyprland session (stops systemd session units first) |
| `SUPER+SHIFT+C` | Reload config (`hyprctl reload`) |

---

## Volume & Media

Volume repeats while held and works on the lock screen.

| Key | Action |
|-----|--------|
| `VolumeUp/Down` | Volume ±5% |
| `Mute` | Toggle mute |
| `MicMute` | Toggle mic mute |
| `MediaPlay/Pause` | Play/pause (`playerctl` — **not installed yet**) |
| `MediaNext/Prev` | Next / previous track (same caveat) |

---

## Brightness

Works on the lock screen.

| Key | Action |
|-----|--------|
| `BrightnessUp/Down` | Backlight ±10% |
| `SUPER+BrightnessUp/Down` | Fine step ±5% |
| `ALT+BrightnessUp/Down` | Keyboard backlight (rocinante only) |
