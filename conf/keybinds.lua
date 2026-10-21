-- conf/keybinds.lua
-- Converted from conf/keybinds.conf.
-- Unlike hyprlang, Lua `require()`d files don't share a global $var namespace,
-- so shared binds that need machine-specific programs must require() them explicitly.

local programs = require("conf.machine.programs")

-- Apps (shared — machine keybinds.lua adds device-specific ones)
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(programs.terminal))
hl.bind("SUPER + B",      hl.dsp.exec_cmd(programs.browser))
hl.bind("SUPER + R",      hl.dsp.exec_cmd("fuzzel"))
hl.bind("SUPER + V",      hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu --width=60 --lines=12 | cliphist decode | wl-copy"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("~/.local/bin/vw"))  -- Vaultwarden picker (rbw)
hl.bind("SUPER + TAB",    hl.dsp.exec_cmd("~/.config/hypr/scripts/window-switcher"))
hl.bind("SUPER + X",      hl.dsp.submap("power"))
hl.bind("SUPER + W",      hl.dsp.submap("resize"))

-- Annotate last screenshot, its layers still editable (see Screenshots below)
hl.bind("SUPER + N", hl.dsp.exec_cmd("~/.cargo/bin/screenie edit last --mode annotate"))

-- Window management
hl.bind("SUPER + Q",         hl.dsp.window.close())
hl.bind("SUPER + F",         hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind("SUPER + SPACE",     hl.dsp.window.float({ action = "toggle" }))

-- Cycle focus tiled → floating 1 → floating 2 → … → tiled (current workspace).
-- Directional focus never crosses from tiled to floating, so this is the bridge.
-- Back to tiled lands on the most recently focused tiled window.
hl.bind("SUPER + SHIFT + SPACE", function()
    local active = hl.get_active_window()
    local ws = active and active.workspace or hl.get_active_workspace()
    if not ws then return end
    local floating, tiled = {}, {}
    for _, w in ipairs(hl.get_windows()) do
        if w.mapped and not w.hidden and w.workspace and w.workspace.id == ws.id then
            table.insert(w.floating and floating or tiled, w)
        end
    end
    table.sort(floating, function(a, b) return a.stable_id < b.stable_id end)
    table.sort(tiled, function(a, b) return a.focus_history_id < b.focus_history_id end)

    local target
    if active and active.floating then
        for i, w in ipairs(floating) do
            if w.address == active.address then target = floating[i + 1] end
        end
        target = target or tiled[1]
    else
        target = floating[1]
    end
    if target and not (active and target.address == active.address) then
        hl.dispatch(hl.dsp.focus({ window = "address:" .. target.address }))
    end
end)
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

-- Screenshots (screenie, the Rust port: `cargo install --path crates/screenie`
-- from screenie's rust/). Plain = clipboard; SUPER = also save a file.
local SCREENIE = "~/.cargo/bin/screenie"
local SHOTS = " --save ~/documents/pictures/screenshots"
hl.bind("Print",                 hl.dsp.exec_cmd(SCREENIE))
hl.bind("SHIFT + Print",         hl.dsp.exec_cmd(SCREENIE .. " shot"))
hl.bind("SUPER + Print",         hl.dsp.exec_cmd(SCREENIE .. SHOTS))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(SCREENIE .. " shot" .. SHOTS))

-- OCR the most recent image (the clipboard's, else the last shot): drag a
-- region or keep the whole image; Enter copies the text and notifies
hl.bind("SUPER + G", hl.dsp.exec_cmd(SCREENIE .. " edit --result text"))

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
        hl.exec_cmd("loginctl lock-session")  -- → hypridle lock_cmd → lockscreen lock
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("SUPER + A", function()
        hl.exec_cmd("~/.config/hypr/scripts/lockscreen away")
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

-- Lockscreen: Enter starts a fingerprint scan (scripts/lockscreen fprint).
-- Kept disabled except while locked — scripts/lockscreen flips it with
-- `hyprctl eval 'LOCKSCREEN_ENTER:set_enabled(...)'` — so Enter is untouched
-- in normal use. non_consuming: hyprlock still gets Enter for a typed password.
LOCKSCREEN_ENTER = hl.bind("RETURN",
    hl.dsp.exec_cmd("~/.config/hypr/scripts/lockscreen fprint"),
    { locked = true, non_consuming = true })
LOCKSCREEN_ENTER:set_enabled(false)

-- Lockscreen power keys, ly-style: F1 off, F2 reboot, F3 suspend, F4 away.
-- Lock-only like LOCKSCREEN_ENTER: scripts/lockscreen calls
-- LOCKSCREEN_POWER(true/false), and `lockscreen power` re-checks that
-- hyprlock is up, so a bind left enabled can never fire unlocked.
-- Wake guard: the press that wakes dark displays (key_press_enables_dpms)
-- can also fire the bind, so F1 on a dark screen could power off. A 100ms
-- watcher notes when any display was last off; a press within ~300ms of
-- that only wakes.
local tick, dark_tick = 0, -100
local dark_watch = hl.timer(function()
    tick = tick + 1
    for _, m in ipairs(hl.get_monitors()) do
        if not m.dpms_status then dark_tick = tick end
    end
end, { timeout = 100, type = "repeat" })

local power_binds = {}
for key, action in pairs({ F1 = "poweroff", F2 = "reboot", F3 = "suspend", F4 = "away" }) do
    power_binds[#power_binds + 1] = hl.bind(key, function()
        for _, m in ipairs(hl.get_monitors()) do
            if not m.dpms_status then return end
        end
        if tick - dark_tick <= 3 then return end
        hl.exec_cmd("~/.config/hypr/scripts/lockscreen power " .. action)
    end, { locked = true })
end

function LOCKSCREEN_POWER(on)
    dark_watch:set_enabled(on)
    for _, b in ipairs(power_binds) do b:set_enabled(on) end
end
LOCKSCREEN_POWER(false)

-- A reload while locked recreates these disabled; re-arm if still locked.
hl.on("config.reloaded", function()
    hl.exec_cmd("~/.config/hypr/scripts/lockscreen rearm")
end)

