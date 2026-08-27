-- conf/keybinds.lua
-- Converted from conf/keybinds.conf.
-- Unlike hyprlang, Lua `require()`d files don't share a global $var namespace,
-- so shared binds that need machine-specific programs must require() them explicitly.

local programs = require("conf.machine.programs")

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
-- resize wants an explicit relative=true for delta-based sizing — without it,
-- x/y are an absolute target size, and a negative delta throws "Invalid size"
-- (found live: this was crashing the dispatcher and stranding the submap).
hl.define_submap("resize", function()
    hl.bind("SUPER + H", hl.dsp.window.resize({ x = -40, y = 0,  relative = true }), { repeating = true })
    hl.bind("SUPER + J", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })
    hl.bind("SUPER + K", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
    hl.bind("SUPER + L", hl.dsp.window.resize({ x = 40,  y = 0,  relative = true }), { repeating = true })
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
