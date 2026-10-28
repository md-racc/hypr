# systemd-managed session daemons

Long-running daemons run as systemd user units bound to
`graphical-session.target` instead of raw `exec-once` lines. Supervision
(`Restart=on-failure`), `journalctl --user -u <unit>` logs, and clean
shutdown ordering — without adopting uwsm. The launcher stays
`start-hyprland`.

## How it works

1. Autostart runs one line:
   `dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && { systemctl --user stop xdg-desktop-portal …; systemctl --user start hyprland-session.target; }`
   The first half pushes the Wayland env into the systemd user manager
   (units have `ConditionEnvironment=WAYLAND_DISPLAY`); the `&&` matters —
   both halves must run in one `exec-once` so the import completes before
   the target starts.
2. `systemd/hyprland-session.target` (this repo) has
   `BindsTo=graphical-session.target`, so starting it pulls
   `graphical-session.target` up, which starts every enabled unit that is
   `WantedBy=graphical-session.target`.
3. Session exit goes through `scripts/session-exit`, which stops
   `graphical-session.target` (stopping all `PartOf=` units) before
   `hyprctl dispatch exit`.

## Units

| Unit | Source | Runs |
|---|---|---|
| hypridle.service | package | idle lock/dpms/suspend |
| hyprsunset.service | package | night light |
| fnott.service | package | notifications (Type=dbus) |
| cliphist-text.service | `systemd/` | clipboard history (text) |
| cliphist-image.service | `systemd/` | clipboard history (image) |
| nextcloud-client.service | `systemd/` | file sync |

Repo units are enabled **by absolute path** (`systemctl --user enable
~/.config/hypr/systemd/foo.service`), which symlinks back into the repo —
edit the repo file, `systemctl --user daemon-reload`, done.

No polkit agent on purpose: terminal commands (`systemctl`, `pkexec`,
`udisksctl`) prompt in the terminal via their built-in fallback agent, which
handles roci's fingerprint fine (empty Enter → sensor). GUI-only admin tools
get "not authorized". Decided 2026-10-02 after a fuzzel agent couldn't submit
an empty field for the fingerprint path.

Still plain `exec-once`: eww (per-machine window set), wallpaper-restore
(one-shot), gnome-keyring (dbus-activated anyway).

## New machine / laptop runbook

```sh
cd ~/.config/hypr && git pull
sudo pacman -S --needed hyprsunset   # if not yet installed
./scripts/setup-session-services     # links + enables everything, idempotent
```

Then either relogin, or take over live without one:

```sh
# stop the legacy exec-once processes
pkill -x hypridle; pkill -x hyprsunset; pkill -x fnott
pkill -f "wl-paste --type"; pkill -x nextcloud
# import env + start the target (same line autostart runs)
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY
systemctl --user start hyprland-session.target
```

Verify: `systemctl --user status graphical-session.target` is active and
`systemctl --user --failed` is empty.

## Notes

- `setup-session-services` skips hyprsunset.service if the binary is
  missing and prints a warning.
- If a unit shows `condition failed` (ConditionEnvironment), the env
  import didn't happen — rerun the `dbus-update-activation-environment`
  line from a terminal inside the session.
- Do NOT `systemctl --user enable hyprland-session.target` itself — it is
  started by autostart, not at user-manager boot.
- Portals can be D-Bus-activated before the env import runs; they then
  have no `WAYLAND_DISPLAY` (gtk portal crash-loops, termfilechooser's
  kitty fails with "DISPLAY environment variable is missing", so file
  dialogs never open). Autostart therefore stops the portal units after
  the import; D-Bus re-activates them on demand with the right env. Live
  fix: `systemctl --user restart xdg-desktop-portal xdg-desktop-portal-termfilechooser`.
