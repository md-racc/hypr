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
