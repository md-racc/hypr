# Hyprland Lua Config Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate this repo's Hyprland configuration from hyprlang (`.conf`) to Lua (`.lua`) ahead of hyprlang's removal from `hyprland.conf` in an upcoming Hyprland release, while preserving current behavior exactly and keeping a safe, instant rollback path.

**Architecture:** One new Lua file per existing `.conf` file, same directory layout, same `source`-order-preserving `require()` chain from a new top-level `hyprland.lua`. `conf/machine` stays the gitignored per-host symlink; only its target's file extensions change. `hypridle.conf` / `hyprlock.conf` / `hyprsunset.conf` are **out of scope** — those tools keep hyprlang. The new `hyprland.lua` is authored and validated entirely via `--verify-config` against copies, and is only placed at the live path `~/.config/hypr/hyprland.lua` in the final cutover task, immediately before a deliberate, user-attended Hyprland restart.

**Tech Stack:** Hyprland 0.56.2 (installed), Hyprland Lua config API (`hl.*`, stubs at `/usr/share/hypr/stubs/hl.meta.lua`), bash, git.

## Global Constraints

- Presence of `~/.config/hypr/hyprland.lua` makes Hyprland load Lua **instead of** `hyprland.conf`, checked only at process startup — not on `hyprctl reload`. Never place the real file at that path until every other task is done and verified.
- `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf` are not touched by this migration.
- No behavior changes. Any place where the literal translation is ambiguous is called out explicitly and verified in Task 8 (live nested-session test) rather than guessed.
- All static syntax checks use `Hyprland --config <file> --verify-config`, which is side-effect-free (confirmed empirically — it does not touch the live compositor).
- Per CLAUDE.md: commits are conventional style, one logical change each, explicit pathspecs only, and any keybind-affecting commit must be checked against `KEYBINDS.md`.
- `conf/machine` remains a gitignored symlink (`ln -s machines/<host> conf/machine`), created per-machine — do not commit it.
- **Both machines get migrated in this pass.** rocinante's sshd is being brought online for this purpose. Transport for verified, committed files is **`git push` from zion → `git pull` on rocinante** (remote is `gitea.lan`) — never `scp` for the real migration files. `scp` is permitted only for throwaway pre-commit spiking (e.g. pushing an uncommitted scratch file to rocinante to test something before it's ready to commit), and anything moved that way is not itself a deliverable.
- Every remote command against rocinante runs over SSH non-interactively (`ssh rocinante '...'`) — confirm the host/user for that alias with the user if not already configured, rather than guessing.
- rocinante's live session is real and in use — treat its cutover restart (Task 11) with the same "confirm before running" caution as zion's (Task 9), even though it's being driven remotely over SSH.

---

## Verified facts (spiked interactively before writing this plan — do not re-derive)

These were confirmed by running real `--verify-config` checks against Hyprland 0.56.2 on this machine, not inferred from docs:

1. **Bind syntax uses `" + "` between mod and key**, e.g. `hl.bind("SUPER + Y", ...)` — not `"SUPER Y"`.
2. **`require()` resolves dotted paths relative to the config file's directory**, including through a symlink: `require("machine.programs")` from `~/.config/hypr/hyprland.lua` correctly loads `~/.config/hypr/conf/machine/programs.lua` (which is itself a symlink target). Confirmed with a live spike.
3. **Each `require()`'d file is its own Lua scope.** A file like `programs.lua` must `return { terminal = "...", ... }`; the requiring file does `local programs = require("conf.machine.programs")` and uses `programs.terminal`. Locals do NOT leak across files like hyprlang's `$var` did.
4. **`hl.dsp.window.resize({ x = ..., y = ... })`** is the Lua equivalent of `resizeactive, X Y`. Confirmed parses.
5. **`hl.define_submap(name, fn)`** (2-arg form) and **`hl.define_submap(name, resetKey, fn)`** (3-arg form) both parse successfully. Which form actually wires the reset key vs. requiring an explicit `hl.bind("Escape", hl.dsp.submap("reset"))` inside the submap body is **not yet confirmed at runtime** — verify in Task 8.
6. **`{ release = true, transparent = true }` bind options** parse and are the intended equivalent of hyprlang's `bindrt` (release + transparent-so-catchall-doesn't-shadow-it, per the CLAUDE.md gotcha) — confirmed to parse, **runtime feel not yet confirmed** — verify in Task 8.
7. **`hl.window_rule({ name, match = { class = "..." }, float = true, ... })`** confirmed to parse for the `windowrule { match:class = ... }` style rules in `rules.conf`.
8. **`hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })`** confirmed to parse (rocinante's touchpad gesture).
9. All `misc.*` and `input.*` keys currently used (`key_press_enables_dpms`, `enable_swallow`, `swallow_regex`, `force_default_wallpaper`, `disable_hyprland_logo`, `vrr`, `kb_options`, `repeat_rate`, `repeat_delay`, `touchpad.disable_while_typing`, `touchpad.natural_scroll`) exist as valid `HL.ConfigKey` entries in the installed stub — no renames needed.
10. **Not yet confirmed at runtime** (flag, don't guess): the old hyprlang `catchall` bind idiom (`bind = , catchall, submap, reset`) has no direct settable equivalent in `HL.BindOptions` — `catchall` only appears as a *read-only* field on an existing `HL.Keybind`. It's possible submap fallthrough behavior changed. Task 8 must confirm unbound keys inside the `resize`/`power` submaps still safely no-op or reset, rather than getting stuck.
11. `$mainMod = SUPER` in `conf/keybinds.conf` is declared but **never referenced** — every bind uses the literal `SUPER` string. It is dropped (not translated) in the Lua version; this is not a behavior change.

---

## File Structure

New files (Lua), existing `.conf` files left untouched until Task 9's cutover:

```
hyprland.lua                              # NEW — orchestrator, created empty/staged, placed live only in Task 9
conf/appearance.lua                       # NEW — from conf/appearance.conf
conf/keybinds.lua                         # NEW — from conf/keybinds.conf
conf/rules.lua                            # NEW — from conf/rules.conf
conf/machines/zion/monitors.lua           # NEW
conf/machines/zion/env.lua                # NEW
conf/machines/zion/programs.lua           # NEW
conf/machines/zion/autostart.lua          # NEW
conf/machines/zion/input.lua              # NEW
conf/machines/zion/keybinds.lua           # NEW
conf/machines/rocinante/monitors.lua      # NEW
conf/machines/rocinante/env.lua           # NEW
conf/machines/rocinante/programs.lua      # NEW
conf/machines/rocinante/autostart.lua     # NEW
conf/machines/rocinante/input.lua         # NEW
conf/machines/rocinante/keybinds.lua      # NEW
```

All old `.conf` files are kept side-by-side (not deleted) until Task 10, so the live session on `zion` is never at risk while Tasks 1–8 run.

A scratch verification helper is used throughout:

```bash
# Usage: verify-lua <file-under-test-that-requires-the-others>
verify-lua() {
  Hyprland --config "$1" --verify-config
}
```

---

### Task 1: Scratch harness for require()-based static verification

Since the real per-machine files use `require("machine.xxx")`, and `conf/machine` doesn't exist as a symlink in a fresh checkout, verification of any file that does `require("machine.*")` needs a scratch copy of the repo tree with the symlink created, pointed at whichever machine you're testing.

**Files:**
- Create: `scripts/verify-lua-config` (bash helper, not committed to `conf/`)

**Interfaces:**
- Produces: `scripts/verify-lua-config <machine>` — copies the repo's Lua files into a scratch dir, symlinks `conf/machine -> conf/machines/<machine>`, and runs `Hyprland --config <scratch>/hyprland.lua --verify-config`.

- [ ] **Step 1: Write the helper script**

```bash
#!/usr/bin/env bash
# scripts/verify-lua-config <machine>
# Static-checks the in-progress Lua config without touching the live session.
set -euo pipefail

machine="${1:?usage: verify-lua-config <zion|rocinante>}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

cp -r "$repo_root/conf" "$scratch/conf"
cp "$repo_root/hyprland.lua" "$scratch/hyprland.lua" 2>/dev/null || true
rm -f "$scratch/conf/machine"
ln -s "$scratch/conf/machines/$machine" "$scratch/conf/machine"

Hyprland --config "$scratch/hyprland.lua" --verify-config
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/verify-lua-config
```

- [ ] **Step 3: Run it against an empty hyprland.lua to confirm the harness itself works**

```bash
touch hyprland.lua.stub
cp hyprland.lua.stub /tmp/hlstub && mv /tmp/hlstub hyprland.lua 2>/dev/null || true
# There is no hyprland.lua yet — expected failure mode is "file not found", not a harness bug.
./scripts/verify-lua-config zion || true
rm -f hyprland.lua.stub
```

Expected: script runs and fails cleanly on the missing `hyprland.lua` (not a bash error) — confirms path/symlink plumbing works. This script will actually pass once Task 7 creates a real `hyprland.lua` in the repo root.

- [ ] **Step 4: Commit**

```bash
git add scripts/verify-lua-config
git commit -m "chore: add Lua config verification harness for hyprlang migration"
```

---

### Task 2: Convert `conf/appearance.lua`

**Files:**
- Create: `conf/appearance.lua`
- Reference (unchanged): `conf/appearance.conf`

**Interfaces:**
- Produces: nothing consumed by other files (appearance has no cross-file variables).

- [ ] **Step 1: Write the file**

```lua
-- conf/appearance.lua
-- Converted from conf/appearance.conf. See docs/superpowers/plans/2026-08-27-hyprland-lua-migration.md.

hl.config({
    general = {
        gaps_in  = 1,
        gaps_out = 2,

        border_size = 1,

        col = {
            active_border   = "rgba(0,66,255,00)",
            inactive_border = "rgba(0,66,255,0)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 1,
        rounding_power = 5,

        shadow = {
            enabled      = false,
            range        = 30,
            render_power = 3,
            color        = "rgb(FFFFFF)",
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            vibrancy          = 0.15,
            vibrancy_darkness = 1.0,
            ignore_opacity    = true,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}   } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",           enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",           enabled = true, speed = 3.77, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",          enabled = true, speed = 3.35, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4.0,  bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1.25, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 1.21, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.02, bezier = "easeOutQuint" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2.12, bezier = "easeOutQuint" })
hl.animation({ leaf = "layers",           enabled = true, speed = 2.67, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 2.8,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.05, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 1.25, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 0.97, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 1.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn",     enabled = true, speed = 1.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut",    enabled = true, speed = 1.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.1,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 4.9,  bezier = "quick" })

hl.config({
    dwindle = {
        -- required for togglesplit/rotatesplit to have any effect — see CLAUDE.md gotchas
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        enable_swallow          = true,
        swallow_regex           = "^(kitty)$",
        -- wake displays from manual dpms-off (away mode) — key-only so desk bumps don't wake
        key_press_enables_dpms  = true,
    },
})
```

- [ ] **Step 2: Verify it parses standalone**

```bash
Hyprland --config conf/appearance.lua --verify-config
```

Expected: `config ok`. (This file has no `require()`, so it verifies directly — no scratch harness needed.)

- [ ] **Step 3: Commit**

```bash
git add conf/appearance.lua
git commit -m "feat: add Lua translation of conf/appearance.conf"
```

---

### Task 3: Convert `conf/rules.lua`

**Files:**
- Create: `conf/rules.lua`
- Reference (unchanged): `conf/rules.conf`

- [ ] **Step 1: Write the file**

```lua
-- conf/rules.lua
-- Converted from conf/rules.conf.

-- Gnome apps
hl.window_rule({ name = "gnome-float", match = { class = "org.gnome.*" }, float = true })

hl.window_rule({
    name  = "calculator-position",
    match = { class = "org.gnome.Calculator" },
    size  = "400 620",
    move  = "6 453",
})

hl.window_rule({
    name  = "calendar-position",
    match = { class = "org.gnome.Calendar" },
    size  = "360 600",
    move  = "6 474",
})

-- Media
hl.window_rule({
    name   = "mpv-float",
    match  = { class = "mpv" },
    float  = true,
    size   = "1280 720",
    center = true,
})

hl.window_rule({ name = "spotify-tile", match = { class = "^(Spotify)$" }, tile = true })

-- System tools
hl.window_rule({ name = "resources-float", match = { class = "net.nokyan.Resources" }, float = true })
hl.window_rule({ name = "portal-float",    match = { class = "xdg-desktop-portal-gtk" }, float = true })

-- File manager
hl.window_rule({ name = "nemo-float", match = { class = "nemo" }, float = true })

-- Scratchpad
hl.window_rule({
    name      = "scratchpad-float",
    match     = { class = "scratchpad" },
    float     = true,
    size      = "900 600",
    center    = true,
    workspace = "special silent",
})

-- Browser extensions
hl.window_rule({
    name  = "bitwarden-popup",
    match = { title = "Extension: \\(Bitwarden Password Manager\\).*" },
    float = true,
    size  = "463 606",
})

-- Qalculate
hl.window_rule({
    name   = "qalculate-float",
    match  = { class = "qalculate-gtk" },
    float  = true,
    size   = "826 557",
    center = true,
})

-- Global rules
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})
```

**Note:** old hyprlang `size = 400 620` used unquoted space-separated ints; `move = (6) (453)` used parens. The example config in the official repo uses bare-string `move = "20 monitor_h-120"` for the equivalent field, so `size`/`move` are passed as `"W H"` / `"X Y"` strings here, matching that pattern — confirm in Task 8's `--verify-config` pass (Step 2 below) and in the live test.

- [ ] **Step 2: Verify it parses standalone**

```bash
Hyprland --config conf/rules.lua --verify-config
```

Expected: `config ok`. If `size`/`move` string format is rejected, try the table form `size = { w = 400, h = 620 }` / `move = { x = 6, y = 453 }` instead — the `HL.WindowRuleSpec` type wasn't fully dumped in the stub excerpt read for this plan; whichever form passes `--verify-config` is correct, since this tool validates against the real installed binary's schema.

- [ ] **Step 3: Commit**

```bash
git add conf/rules.lua
git commit -m "feat: add Lua translation of conf/rules.conf"
```

---

### Task 4: Convert `conf/keybinds.lua` (shared binds + submaps)

This is the highest-risk file: it contains the resize/power submaps called out as gotchas in CLAUDE.md.

**Files:**
- Create: `conf/keybinds.lua`
- Reference (unchanged): `conf/keybinds.conf`

**Interfaces:**
- Consumes: nothing (this file only uses literal command strings, not machine-specific `$terminal`/`$browser` — those are consumed by machine `keybinds.lua` files in Task 5/6, matching how the current `.conf` split works: shared `keybinds.conf` doesn't reference `$terminal`/`$browser` either except via the machine's own `programs.conf`).

Wait — check: shared `keybinds.conf` DOES reference `$terminal` and `$browser` (lines `exec, $terminal` / `exec, $browser`), which are defined in the **machine's** `programs.conf`. In hyprlang, `$vars` are global across all sourced files regardless of source order relative to definition, because hyprlang evaluates them as a flat namespace. **Lua does not do this** (see verified fact #3) — `conf/keybinds.lua` cannot see locals from `conf/machine/programs.lua` unless it explicitly `require()`s it. Since `programs.conf` is sourced by `hyprland.conf` before `keybinds.conf` today, replicate the dependency explicitly:

- Consumes: `require("machine.programs")` → `{ terminal: string, browser: string, fileManager: string, taskmanager: string, notes: string, ide: string }`

- [ ] **Step 1: Write the file**

```lua
-- conf/keybinds.lua
-- Converted from conf/keybinds.conf.
-- Unlike hyprlang, Lua `require()`d files don't share a global $var namespace,
-- so shared binds that need machine-specific programs must require() them explicitly.

local programs = require("machine.programs")

-- Apps (shared — machine keybinds.lua adds device-specific ones)
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(programs.terminal))
hl.bind("SUPER + B",      hl.dsp.exec_cmd(programs.browser))
hl.bind("SUPER + R",      hl.dsp.exec_cmd("fuzzel"))
hl.bind("SUPER + V",      hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind("SUPER + TAB",    hl.dsp.exec_cmd("~/.config/hypr/scripts/window-switcher"))
hl.bind("SUPER + X",      hl.dsp.submap("power"))
hl.bind("SUPER + W",      hl.dsp.submap("resize"))

-- Annotate last screenshot (see Screenshots below)
hl.bind("SUPER + N", hl.dsp.exec_cmd([[bash -c 'f=$(cat /tmp/last-screenshot 2>/dev/null) && [ -f "$f" ] && satty --filename "$f"']]))

-- Window management
hl.bind("SUPER + Q",         hl.dsp.window.kill())
hl.bind("SUPER + F",         hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind("SUPER + SPACE",     hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + S",         hl.dsp.layout("togglesplit"))
hl.bind("SUPER + SHIFT + S", hl.dsp.layout("rotatesplit"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("~/.config/hypr/scripts/resetsplits"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))

-- Focus (HJKL)
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))

-- Move windows (HJKL) — crosses to adjacent workspace at horizontal edge
hl.bind("SUPER + SHIFT + H", hl.dsp.exec_cmd("~/.config/hypr/scripts/movewindow l"))
hl.bind("SUPER + SHIFT + J", hl.dsp.exec_cmd("~/.config/hypr/scripts/movewindow d"))
hl.bind("SUPER + SHIFT + K", hl.dsp.exec_cmd("~/.config/hypr/scripts/movewindow u"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/movewindow r"))

-- Special workspace (scratchpad)
hl.bind("SUPER + grave",         hl.dsp.workspace.toggle_special("special"))
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special" }))

-- Workspaces 1-10, and move window to workspace
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind("SUPER + CTRL + " .. key,  hl.dsp.exec_cmd("~/.config/hypr/scripts/workspace-send-all " .. i))
end

-- Scroll workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Session
hl.bind("SUPER + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/session-exit"))

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- Media (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",           hl.dsp.exec_cmd("brightnessctl set +10%"), { locked = true })
hl.bind("XF86MonBrightnessDown",         hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true })
hl.bind("SUPER + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"),  { locked = true })
hl.bind("SUPER + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),  { locked = true })

-- Screenshots — to clipboard
hl.bind("Print",       hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot area   clip"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot active clip"))
-- Screenshots — to file (notification has actions: swayimg / ranger / kitty)
hl.bind("SUPER + Print",         hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot area   file"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot active file"))

-- OCR: extract text from the most recent screenshot (clipboard) and copy it
hl.bind("SUPER + G", hl.dsp.exec_cmd([[bash -c 'text=$(textgrab); [ -n "$text" ] && notify-send "textgrab" "${text:0:200}"']]))

-------------------------
---- RESIZE SUBMAP ------
-------------------------
-- Hold SUPER+W, mash HJKL to resize, release W to exit.
-- VERIFY IN TASK 8: does an unbound key inside this submap fall through / get
-- stuck the way hyprlang's `bind = , catchall, submap, reset` used to prevent?
hl.define_submap("resize", function()
    hl.bind("SUPER + H", hl.dsp.window.resize({ x = -40, y = 0 }), { repeating = true })
    hl.bind("SUPER + J", hl.dsp.window.resize({ x = 0,   y = 40 }), { repeating = true })
    hl.bind("SUPER + K", hl.dsp.window.resize({ x = 0,   y = -40 }), { repeating = true })
    hl.bind("SUPER + L", hl.dsp.window.resize({ x = 40,  y = 0 }), { repeating = true })
    hl.bind("SUPER + W", hl.dsp.submap("reset"), { release = true, transparent = true })
    hl.bind("W",         hl.dsp.submap("reset"), { release = true, transparent = true })
    hl.bind("Escape",    hl.dsp.submap("reset"))
end)

-------------------------
---- POWER SUBMAP -------
-------------------------
hl.define_submap("power", function()
    hl.bind("SUPER + L", function()
        hl.exec_cmd("~/.config/hypr/scripts/hyprlock-blur")
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("SUPER + A", function()
        hl.exec_cmd("~/.config/hypr/scripts/away-mode")
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("SUPER + P", hl.dsp.exec_cmd("systemctl poweroff"))
    hl.bind("SUPER + R", hl.dsp.exec_cmd("systemctl reboot"))
    hl.bind("SUPER + S", function()
        hl.exec_cmd("systemctl suspend")
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("SUPER + O", hl.dsp.exec_cmd("~/.config/hypr/scripts/session-exit"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- Lockscreen power (locked flag = fires while locked; submap can't be entered while locked)
-- Requires SHIFT to avoid colliding with normal SUPER+P/R binds, which `locked` doesn't restrict to locked-only
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("systemctl poweroff"), { locked = true })
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("systemctl reboot"),   { locked = true })
```

Notes on translation decisions made here:
- `killactive` (no-arg dispatcher) → `hl.dsp.window.kill()`.
- `fullscreen, 1` → `hl.dsp.window.fullscreen({ mode = 1 })` — field name `mode` is a best-effort guess for `HL.DspWindowNamespace.fullscreen`'s options table; **verify in Task 4 Step 2** and adjust the key name to whatever `--verify-config` accepts.
- `layoutmsg, togglesplit` → `hl.dsp.layout("togglesplit")`, matching the official example's `hl.dsp.layout("togglesplit")` usage for the identical dwindle-only dispatcher.
- Power submap's two-actions-per-key (`exec` then `submap, reset` as two separate hyprlang binds on the same key) collapse into one Lua function-dispatcher bind each, since Lua binds accept a plain function body (per `HL.API.bind`'s `dispatcher: HL.Dispatcher|function` signature) — this is simpler and behaviorally identical (both run on the same keypress).
- `catchall` bind removed for the power submap (relying on `Escape` only); resize submap keeps both the release-based reset and an `Escape` fallback. **Verify no other key can get stuck in either submap in Task 8** — if it can, add back an explicit catch based on whatever runtime testing shows works.

- [ ] **Step 2: Verify it parses (needs the require() harness from Task 1)**

```bash
# conf/keybinds.lua alone can't verify (it requires "machine.programs"),
# so route through the harness once a machine's programs.lua exists (Task 5).
# For now, sanity check syntax in isolation with a stub:
mkdir -p /tmp/keybind-check/machine
cat > /tmp/keybind-check/machine/programs.lua <<'EOF'
return { terminal = "kitty", browser = "firefox", fileManager = "kitty ranger", taskmanager = "kitty btop", notes = "obsidian", ide = "kitty nvim" }
EOF
cp conf/keybinds.lua /tmp/keybind-check/test.lua
sed -i 's#require("machine.programs")#require("machine.programs")#' /tmp/keybind-check/test.lua
Hyprland --config /tmp/keybind-check/test.lua --verify-config
```

Expected: `config ok`, or specific field-name errors on `fullscreen`/`move`/`toggle_special` — fix the exact option-table keys named in the error and re-run until clean. Trust `--verify-config`'s error output over anything guessed in this plan.

- [ ] **Step 3: Commit**

```bash
git add conf/keybinds.lua
git commit -m "feat: add Lua translation of conf/keybinds.conf (submaps included)"
```

---

### Task 5: Convert zion's machine files

**Files:**
- Create: `conf/machines/zion/monitors.lua`, `env.lua`, `programs.lua`, `autostart.lua`, `input.lua`, `keybinds.lua`

**Interfaces:**
- Produces: `conf/machines/zion/programs.lua` returns `{ terminal, fileManager, taskmanager, browser, notes, ide }` — the exact shape `conf/keybinds.lua` (Task 4) and this file's own `keybinds.lua` consume.

- [ ] **Step 1: `conf/machines/zion/monitors.lua`**

```lua
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75",  position = "0x0",    scale = 1 })
hl.monitor({ output = "DP-3",     mode = "1920x1080@165", position = "1920x0", scale = 1 })

-- VRR for FreeSync panels — fullscreen apps only, no desktop flicker
hl.config({
    misc = {
        vrr = 2,
    },
})
```

- [ ] **Step 2: `conf/machines/zion/env.lua`**

```lua
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("GSK_RENDERER", "gl")
```

- [ ] **Step 3: `conf/machines/zion/programs.lua`**

```lua
return {
    terminal    = "kitty -e /bin/zsh",
    fileManager = "kitty ranger",
    taskmanager = "kitty btop",
    browser     = "firefox",
    notes       = "obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland",
    ide         = "kitty nvim",
}
```

- [ ] **Step 4: `conf/machines/zion/autostart.lua`**

```lua
-- Daemons are systemd user units under graphical-session.target —
-- see docs/systemd-session.md. Env import and target start must share
-- one exec-once so they run in order.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user start hyprland-session.target")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("eww open clock-win")
    hl.exec_cmd("eww open ws-win")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11,ssh")
end)
```

- [ ] **Step 5: `conf/machines/zion/input.lua`**

```lua
hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "caps:escape",

        follow_mouse = 1,
        sensitivity  = -0.75,

        repeat_rate  = 35,
        repeat_delay = 250,

        touchpad = {
            natural_scroll = true,
        },
    },
})
```

- [ ] **Step 6: `conf/machines/zion/keybinds.lua`**

```lua
local programs = require("machine.programs")

hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("SUPER + P", hl.dsp.exec_cmd(programs.taskmanager))
hl.bind("SUPER + T", hl.dsp.exec_cmd(programs.ide))
hl.bind("SUPER + O", hl.dsp.exec_cmd(programs.notes))
hl.bind("SUPER + C", hl.dsp.exec_cmd("qalculate-gtk"))
```

- [ ] **Step 7: Verify the full zion tree parses together**

```bash
./scripts/verify-lua-config zion
```

Expected: fails only on the still-missing top-level `hyprland.lua` (Task 7), not on anything in `conf/machines/zion/*`. To isolate zion-only errors before `hyprland.lua` exists, temporarily point the harness at a throwaway orchestrator:

```bash
scratch=$(mktemp -d)
cp -r conf "$scratch/conf"
rm -f "$scratch/conf/machine"
ln -s "$scratch/conf/machines/zion" "$scratch/conf/machine"
cat > "$scratch/hyprland.lua" <<'EOF'
require("conf.machine.monitors")
require("conf.machine.env")
require("conf.machine.autostart")
require("conf.appearance")
require("conf.machine.input")
require("conf.keybinds")
require("conf.machine.keybinds")
require("conf.rules")
EOF
Hyprland --config "$scratch/hyprland.lua" --verify-config
rm -rf "$scratch"
```

Expected: `config ok`.

- [ ] **Step 8: Commit**

```bash
git add conf/machines/zion/monitors.lua conf/machines/zion/env.lua conf/machines/zion/programs.lua conf/machines/zion/autostart.lua conf/machines/zion/input.lua conf/machines/zion/keybinds.lua
git commit -m "feat: add Lua translation of zion machine config"
```

---

### Task 6: Convert rocinante's machine files

**Files:**
- Create: `conf/machines/rocinante/monitors.lua`, `env.lua`, `programs.lua`, `autostart.lua`, `input.lua`, `keybinds.lua`

- [ ] **Step 1: `conf/machines/rocinante/monitors.lua`**

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
```

- [ ] **Step 2: `conf/machines/rocinante/env.lua`**

```lua
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("GSK_RENDERER", "gl")
```

- [ ] **Step 3: `conf/machines/rocinante/programs.lua`**

```lua
return {
    terminal    = "kitty -e /bin/zsh",
    fileManager = "kitty ranger",
    taskmanager = "kitty btop",
    browser     = "firefox",
    notes       = "obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland",
    ide         = "kitty nvim",
}
```

- [ ] **Step 4: `conf/machines/rocinante/autostart.lua`**

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user start hyprland-session.target")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11,ssh")
end)
```

- [ ] **Step 5: `conf/machines/rocinante/input.lua`**

```lua
hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "caps:escape",

        follow_mouse = 1,
        sensitivity  = 0,

        repeat_rate  = 35,
        repeat_delay = 250,

        touchpad = {
            natural_scroll        = true,
            disable_while_typing  = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

- [ ] **Step 6: `conf/machines/rocinante/keybinds.lua`**

```lua
local programs = require("machine.programs")

hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("SUPER + P", hl.dsp.exec_cmd(programs.taskmanager))
hl.bind("SUPER + T", hl.dsp.exec_cmd(programs.ide))
hl.bind("SUPER + O", hl.dsp.exec_cmd(programs.notes))
hl.bind("SUPER + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/netmenu"))

hl.bind("SUPER + Z", hl.dsp.exec_cmd("eww open bar --toggle"))

-- Keyboard backlight (tpacpi::kbd_backlight, max 2)
hl.bind("ALT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d tpacpi::kbd_backlight set +1"), { locked = true })
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d tpacpi::kbd_backlight set 1-"), { locked = true })
```

**Note:** `hl.bind("SUPER + Z", ...)` toggling `eww open bar --toggle` collides with `--toggle` being an eww-side flag, not a Hyprland one — this is a literal 1:1 port of existing behavior, not a new decision.

- [ ] **Step 7: Verify the full rocinante tree parses together (same throwaway-orchestrator technique as Task 5 Step 7, pointed at `conf/machines/rocinante`)**

```bash
scratch=$(mktemp -d)
cp -r conf "$scratch/conf"
rm -f "$scratch/conf/machine"
ln -s "$scratch/conf/machines/rocinante" "$scratch/conf/machine"
cat > "$scratch/hyprland.lua" <<'EOF'
require("conf.machine.monitors")
require("conf.machine.env")
require("conf.machine.autostart")
require("conf.appearance")
require("conf.machine.input")
require("conf.keybinds")
require("conf.machine.keybinds")
require("conf.rules")
EOF
Hyprland --config "$scratch/hyprland.lua" --verify-config
rm -rf "$scratch"
```

Expected: `config ok`. Full live verification on rocinante happens over SSH in Task 11, once zion's cutover (Task 9) has proven the same files' runtime behavior — rocinante only needs its machine-specific deltas (monitors, gestures, keyboard-backlight binds) spot-checked, not the whole shared surface re-verified from scratch.

- [ ] **Step 8: Commit**

```bash
git add conf/machines/rocinante/monitors.lua conf/machines/rocinante/env.lua conf/machines/rocinante/programs.lua conf/machines/rocinante/autostart.lua conf/machines/rocinante/input.lua conf/machines/rocinante/keybinds.lua
git commit -m "feat: add Lua translation of rocinante machine config"
```

---

### Task 7: Write the top-level `hyprland.lua` orchestrator (staged, not live yet)

**Files:**
- Create: `hyprland.lua` (in the repo root — this is the exact live path, but see Global Constraints: it does nothing until Hyprland restarts, and current `hyprland.conf` keeps running the live session)

- [ ] **Step 1: Write the file**

```lua
-- hyprland.lua
-- Lua replacement for hyprland.conf. Source order preserved 1:1 from the
-- old `source = ...` chain. conf/machine is the gitignored per-host symlink
-- (see CLAUDE.md) — unchanged mechanism, now pointing at .lua files.

require("conf.machine.monitors")
require("conf.machine.env")
require("conf.machine.programs")
require("conf.machine.autostart")
require("conf.appearance")
require("conf.machine.input")
require("conf.keybinds")
require("conf.machine.keybinds")
require("conf.rules")

hl.config({
    xwayland = {
        enabled = true,
    },
})
```

**Flag for the user, not silently changed:** CLAUDE.md states "XWayland is disabled globally," but the current `hyprland.conf` has `xwayland { enabled = true }`. This plan preserves *actual current runtime behavior* (`enabled = true`) rather than what the docs claim, since the goal is a behavior-preserving migration. Reconciling that discrepancy (fixing the doc, or actually disabling XWayland) is a separate decision outside this plan's scope — call it out to the user when this task is reviewed.

**Note on `require("conf.machine.programs")` at the top level:** the old `hyprland.conf` sources `programs.conf` for its `$var` side effects, but Lua's `programs.lua` `return`s a table with no side effects — nothing else in `hyprland.lua` needs its return value, so the plain `require()` call is only useful if some other same-scope code in this file uses it (currently none). Keep the `require()` for load-order parity and forward-compatibility, but note that omitting it entirely from `hyprland.lua` (letting `conf/keybinds.lua` and `conf/machine/keybinds.lua` `require()` it lazily on their own) would work identically. **Decision: keep it explicit**, matching the visual structure of the old file.

- [ ] **Step 2: Verify with the harness for both machines**

```bash
./scripts/verify-lua-config zion
./scripts/verify-lua-config rocinante
```

Expected: `config ok` for both.

- [ ] **Step 3: Commit**

```bash
git add hyprland.lua
git commit -m "feat: add top-level hyprland.lua orchestrator (not yet live)"
```

---

### Task 8: Live nested-session test (before touching the real config path)

This is where the runtime-only unknowns flagged in "Verified facts" items 5, 6, 10 and Task 3's `size`/`move` format get resolved empirically, without risking the live `zion` session.

**Files:** none created — this is a manual/scripted verification task. If any fix is needed, it lands as an amendment to the files from Tasks 2-7 (re-run their commits' `--verify-config` step after fixing, then amend or add a small follow-up commit).

- [ ] **Step 1: Launch a nested Hyprland instance against the staged config**

```bash
scratch=$(mktemp -d)
cp -r conf "$scratch/conf"
cp hyprland.lua "$scratch/hyprland.lua"
rm -f "$scratch/conf/machine"
ln -s "$scratch/conf/machines/zion" "$scratch/conf/machine"

# Nest inside the current live Wayland session (like sway --nested).
WAYLAND_DISPLAY="$WAYLAND_DISPLAY" Hyprland --config "$scratch/hyprland.lua"
```

Expected: a nested Hyprland window opens inside the current desktop. If Hyprland refuses to nest under the current backend, fall back to switching to an unused VT (e.g. `Ctrl+Alt+F3`) and running the same command from a plain TTY login — this launches a second, fully separate Hyprland instance without touching the primary session running from the current VT.

- [ ] **Step 2: Inside the nested session, manually check each flagged unknown**

  - Press and hold `SUPER+W`, mash `H`/`J`/`K`/`L` to confirm resize repeats smoothly, then release `W` — window should stop resizing immediately (confirms fact #6 `release+transparent` equivalence to `bindrt`).
  - While in the resize submap, press an unbound key (e.g. `A`) and confirm it doesn't leave you stuck unable to exit — `Escape` should still work regardless (confirms/resolves fact #10).
  - Enter `SUPER+X` (power submap), confirm `L`/`A`/`S` each fire their script AND drop back out of the submap in one press (confirms the function-dispatcher-as-two-actions translation in Task 4).
  - Trigger each `rules.lua` window rule by opening a matching app (or `hyprctl dispatch exec <app>` inside the nested session) and confirm float/size/position/tile land correctly — resolves Task 3's `size`/`move` string-vs-table format question.
  - Confirm `SUPER+F` fullscreens (resolves the `fullscreen({ mode = 1 })` field-name guess from Task 4).
  - Confirm workspace switch/move binds (`SUPER+1..0`, `SUPER+SHIFT+1..0`) work as a spot check on the `for` loop translation.

- [ ] **Step 3: Fix anything broken, re-verify with `--verify-config`, then re-test in the nested session until all of the above pass**

- [ ] **Step 4: Exit the nested session and clean up**

```bash
rm -rf "$scratch"
```

- [ ] **Step 5: Commit any fixes made during this task**

```bash
git add -A conf/ hyprland.lua
git commit -m "fix: correct Lua config issues found in live nested-session testing"
```

(Skip this commit if Step 2 found nothing to fix.)

---

### Task 9: Cutover on zion

**This step restarts the live compositor. Confirm with the user immediately before running it** — save open work, since Hyprland restart normally drops all windows (nothing here restores session state).

**Files:**
- Modify: rename `hyprland.conf` → `hyprland.conf.bak` (rollback artifact, gitignored-or-not per user preference — recommend keeping it tracked in git history via `git mv` so it's recoverable from the commit even if later deleted)
- Effectively activates: `hyprland.lua` (already committed in Task 7)

- [ ] **Step 1: Confirm all prior tasks' `--verify-config` and nested-session checks passed clean**

- [ ] **Step 2: Back up the old config with git history intact**

```bash
git mv hyprland.conf hyprland.conf.bak
git commit -m "chore: retire hyprland.conf in favor of hyprland.lua (see migration plan)"
```

- [ ] **Step 3: Restart Hyprland (user-attended — confirm before running)**

```bash
hyprctl dispatch exit
# then relaunch the session the normal way (start-hyprland), per CLAUDE.md session workflow
```

- [ ] **Step 4: Verify the live session**

```bash
hyprctl configerrors
```

Expected: no errors. Then manually re-run the Task 8 Step 2 checklist against the real, live session (resize submap, power submap, window rules, fullscreen, workspace binds) plus autostart daemons (eww widgets, wallpaper, gnome-keyring) actually launching.

- [ ] **Step 5: Rollback path, if anything is wrong**

```bash
mv hyprland.lua hyprland.lua.bak
git mv hyprland.conf.bak hyprland.conf
hyprctl dispatch exit
# relaunch — old hyprlang config takes over immediately since hyprland.lua no longer exists at the live path
```

- [ ] **Step 6: Push once zion is confirmed good**

```bash
git push
```

This is the point where rocinante is allowed to pull real, verified files — nothing before this step should reach rocinante except throwaway `scp` spikes.

---

### Task 10: Docs and cleanup

**Scope note:** this task covers zion and the shared (non-machine-specific) `.conf` files only. rocinante's own `.conf` cleanup happens in Task 11 once its cutover is confirmed — don't delete rocinante's machine files here even though they're sitting right next to zion's in this repo.

**Files:**
- Modify: `CLAUDE.md` (architecture section — mention `.lua` now; update "Queued: Lua config migration" line under Known state/pending to reflect completion)
- Modify: `KEYBINDS.md` (spot-check only — no keybind behavior changed, so this should need no content changes, but CLAUDE.md requires checking it on any keybind-touching commit)
- Delete (once confident, separate commit, user's call on timing): `hyprland.conf.bak`, `conf/appearance.conf`, `conf/keybinds.conf`, `conf/rules.conf`, and zion's `conf/machines/zion/*.conf` files except `hypridle.conf`/`hyprlock.conf`

- [ ] **Step 1: Update CLAUDE.md's Architecture section**

Add a line noting hyprland's own config is now Lua (`hyprland.lua` + `conf/*.lua`), while `hypridle`/`hyprlock`/`hyprsunset` remain hyprlang `.conf` (those tools didn't move to Lua).

- [ ] **Step 2: Update CLAUDE.md's Known state / pending section**

Replace `Queued: Lua config migration (hyprlang deprecated as of Hyprland 0.55).` with a line noting it's done, and the date.

- [ ] **Step 3: Review KEYBINDS.md against the new `conf/keybinds.lua` / machine `keybinds.lua` files for accuracy**

No bind changed meaning, so this should be a no-op diff — confirm and move on.

- [ ] **Step 4: Commit doc updates**

```bash
git add CLAUDE.md KEYBINDS.md
git commit -m "docs: record completed Lua config migration"
```

- [ ] **Step 5 (separate, later commit — not required same-day): remove zion's now-dead `.conf` files**

```bash
git rm hyprland.conf.bak conf/appearance.conf conf/keybinds.conf conf/rules.conf \
  conf/machines/zion/monitors.conf conf/machines/zion/env.conf conf/machines/zion/programs.conf \
  conf/machines/zion/autostart.conf conf/machines/zion/input.conf conf/machines/zion/keybinds.conf
git commit -m "chore: remove zion's hyprlang configs superseded by Lua migration"
```

Do this only after living on the Lua config for a while with no regressions found — it's the point of no easy rollback. rocinante's equivalent `.conf` files are removed separately in Task 11.

---

### Task 11: Migrate rocinante

Everything up to here happened on zion. This task rolls the already-verified files out to rocinante over SSH, using `git pull` as the transport (per Global Constraints — no `scp` of real deliverables). Requires rocinante's sshd to be reachable and Task 9 Step 6 (`git push`) already done.

**Files:** none new — this task deploys and cuts over files already committed in Tasks 2-7 and 10.

- [ ] **Step 1: Confirm SSH reachability and pull the verified config**

```bash
ssh rocinante 'cd ~/.config/hypr && git pull'
```

Expected: fast-forwards cleanly, bringing in `hyprland.lua` and every `conf/*.lua` file, with `conf/machine` still a valid symlink to `conf/machines/rocinante` (untouched by git, since it's gitignored) and rocinante's own `hyprland.conf` still in place and still the live config (nothing switches until `hyprland.lua` is confirmed loadable and a restart happens).

- [ ] **Step 2: Static-verify on rocinante itself (not cross-compiled guesses from zion)**

```bash
ssh rocinante 'cd ~/.config/hypr && Hyprland --config hyprland.lua --verify-config'
```

Expected: `config ok`. If rocinante is on a different Hyprland version than zion's 0.56.2, re-check version-sensitive items from this plan's "Verified facts" section against `ssh rocinante 'Hyprland --version'` and the local stub at `ssh rocinante 'cat /usr/share/hypr/stubs/hl.meta.lua'` before trusting them — don't assume zion's spike results transfer across a version gap.

- [ ] **Step 3: Live nested-session test over SSH, to the extent SSH allows**

Non-interactive checks (fully automatable over SSH, run against the *current, still-live* hyprlang session — these confirm the machine/environment side, not the new Lua file's runtime behavior yet):

```bash
ssh rocinante 'hyprctl configerrors'
ssh rocinante 'hyprctl binds -j' | jq length   # sanity count vs. current .conf-based binds
```

Interactive checks (resize/power submap feel, window rules, the rocinante-specific 3-finger gesture, keyboard-backlight binds) need a keyboard/trackpad physically at rocinante and can't be driven blind over SSH — hand the Task 8-style checklist to the user to run locally on rocinante using the same nested-Hyprland-instance technique, or skip straight to Step 4's real cutover if the user is physically at the machine and would rather test live than nested.

- [ ] **Step 4: Cutover on rocinante — confirm with the user immediately before running (drops rocinante's windows on restart)**

```bash
ssh rocinante 'cd ~/.config/hypr && git mv hyprland.conf hyprland.conf.bak && git commit -m "chore: retire hyprland.conf in favor of hyprland.lua (see migration plan)"'
ssh rocinante 'hyprctl dispatch exit'
# user (or a subsequent SSH session once the box is back up) relaunches via start-hyprland
```

- [ ] **Step 5: Verify the live rocinante session**

```bash
ssh rocinante 'hyprctl configerrors'
```

Expected: no errors. Have the user spot-check the rocinante-specific deltas in person: 3-finger touchpad workspace gesture, `SUPER+Z` eww bar toggle, `ALT+XF86MonBrightness{Up,Down}` keyboard backlight, `SUPER+C` netmenu.

- [ ] **Step 6: Rollback path, if anything is wrong**

```bash
ssh rocinante 'cd ~/.config/hypr && mv hyprland.lua hyprland.lua.bak && git mv hyprland.conf.bak hyprland.conf && hyprctl dispatch exit'
```

- [ ] **Step 7: Push the rocinante cutover commit, then clean up rocinante's dead `.conf` files (separate commit, after living on it a while)**

```bash
ssh rocinante 'cd ~/.config/hypr && git push'
git pull   # sync zion's checkout so both machines' git history matches
git rm conf/machines/rocinante/monitors.conf conf/machines/rocinante/env.conf conf/machines/rocinante/programs.conf \
  conf/machines/rocinante/autostart.conf conf/machines/rocinante/input.conf conf/machines/rocinante/keybinds.conf \
  hyprland.conf.bak 2>/dev/null || true
git commit -m "chore: remove rocinante's hyprlang configs superseded by Lua migration" || true
git push
ssh rocinante 'cd ~/.config/hypr && git pull'
```

(The `hyprland.conf.bak` here is rocinante's own backup, tracked in rocinante's checkout — since both machines share one git history, this step reconciles whichever backup file is still present after both cutovers are confirmed stable.)

---

## Self-Review

**Spec coverage:** every `.conf` file in the repo (Task 2-7), plus the require()-scope pitfall (Task 4 note), the risky live cutover on zion (Task 9, with explicit user-confirmation gate and rollback) and on rocinante (Task 11, same gate, driven over SSH with git pull/push as the only transport for real files), and doc updates (Task 10) are all covered. `hypridle.conf`/`hyprlock.conf`/`hyprsunset.conf` are explicitly out of scope per the research finding that those tools don't move to Lua.

**Placeholder scan:** all Lua code blocks are complete, real translations of the actual files read from this repo — no `-- TODO` or `-- fill in` markers. The handful of genuinely uncertain items (submap reset-key wiring, `fullscreen` option field name, `size`/`move` string vs. table format, catchall equivalent) are called out explicitly with a concrete verification step in Task 8/Task 3, rather than asserted as fact — this is intentional, not a placeholder, since those facts are only knowable by running the real binary.

**Type/interface consistency:** `programs.lua`'s returned table shape (`terminal, fileManager, taskmanager, browser, notes, ide`) is identical across zion (Task 5) and rocinante (Task 6), and matches every `programs.xxx` field accessed in `conf/keybinds.lua` (Task 4) and both machines' `keybinds.lua` files.
