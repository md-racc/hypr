# Hyprland config

Multi-machine Hyprland configuration. `hyprland.conf` is only `source` lines;
everything lives under `conf/`.

## Architecture

- `conf/machine` is a **gitignored symlink** to `conf/machines/<hostname>/`,
  created once per machine (`ln -s machines/<host> conf/machine`). Shared config
  (`appearance.conf`, `keybinds.conf`, `rules.conf`) applies everywhere;
  per-machine dirs hold `monitors`, `env`, `programs`, `autostart`, `input`,
  extra keybinds, and `hyprlock`/`hypridle` configs.
- Machines: **zion** — desktop, DP-3 (1080p@165, VRR fullscreen-only) +
  HDMI-A-1 (1080p@75), eww clock/workspace widgets. **rocinante** — ThinkPad,
  eDP-1, touchpad gestures, keyboard-backlight binds.
- Session: launched via `start-hyprland` (not uwsm). Long-running daemons are
  **systemd user units** under `graphical-session.target`, pulled up by
  `hyprland-session.target` from autostart — see `docs/systemd-session.md`.
  Custom units live in `systemd/` (repo is source of truth; enabled by
  absolute path). New machine setup: `scripts/setup-session-services`.
- Session exit goes through `scripts/session-exit` (stops the session target,
  then `hyprctl dispatch exit`). Never bind bare `hyprctl dispatch exit`.
- XWayland is disabled globally.

## Gotchas (hard-won, do not relearn)

- **hypridle crashes at startup if `~/.config/hypr/hypridle.conf` is missing,
  even when `-c` points to a valid file** (hypridle 0.1.7). The top-level
  `hypridle.conf` is a tracked symlink to `conf/machine/hypridle.conf` for this
  reason — do not delete it.
- `hyprctl configerrors` only validates the hyprland.conf chain — hypridle,
  hyprlock, and hyprsunset configs are NOT checked. hypridle silently ignores
  unknown options (an invented `inhibitor` block lingered for months unnoticed).
- `dwindle:preserve_split = true` (appearance.conf) is required for
  `togglesplit`/`rotatesplit` to do anything; without it they silently no-op.
- The resize submap is hold-style: HJKL binds carry the SUPER modifier (it's
  still held), and `bindrt` (release + transparent) on W exits — transparent
  is needed so the catchall doesn't shadow the release.
- `hyprctl dispatch exec` parents processes to the session; use it instead of
  plain `&` when starting daemons from a shell.
- When testing binds, `hyprctl keyword bind ...` adds a temporary bind that
  vanishes on the next `hyprctl reload`.

## Workflow

- After config edits: `hyprctl reload && hyprctl configerrors`.
- Inspect live binds with `hyprctl binds -j | jq`.
- Commits: conventional style (`feat:`/`fix:`/`chore:`), one logical change
  each, **always pass explicit pathspecs to `git commit`** — the index may
  hold staged deletions that a bare commit would swallow.
- `KEYBINDS.md` is the human-readable bind reference — any commit that
  changes keybinds must update it in the same commit.
- Remote is `gitea.lan`; push only when asked.

## Known state / pending

- Night light: `hyprsunset.conf` steps 6200K→4500K, 20:00–20:30 (GNV sunset).
- Known-broken, fix pending: zion hypridle `inhibitor` blocks are invalid
  syntax (ignored); suspend does not lock first (no `before_sleep_cmd`);
  `scripts/resetsplits` uses a nonexistent layoutmsg; zion hyprlock avatar
  path is dead; `scripts/window-switcher` picks wrong window on duplicate
  titles; playerctl not installed (media keys dead).
- Queued: Lua config migration (hyprlang deprecated as of Hyprland 0.55).
