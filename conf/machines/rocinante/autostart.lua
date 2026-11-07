hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && { systemctl --user stop xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-termfilechooser; systemctl --user reset-failed xdg-desktop-portal-gtk; systemctl --user start hyprland-session.target; }")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper-restore")
    hl.exec_cmd("eww daemon")
    -- gnome-keyring-daemon.socket is masked here (unlike zion), so this is the keyring
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11")
end)
