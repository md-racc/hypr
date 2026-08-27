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
