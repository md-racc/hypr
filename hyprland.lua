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
        enabled = false,
    },
})

-- Per-scheme overrides (decoration.blur) written by `theme` (wallust) from the
-- scheme JSON's optional "hyprland" key. Empty/missing file = values above.
-- Loaded without pcall so mistakes show up in `hyprctl configerrors`.
local theme_overrides = os.getenv("HOME") .. "/.cache/wallust/hypr-theme.lua"
local fh = io.open(theme_overrides)
if fh then
    fh:close()
    dofile(theme_overrides)
end
