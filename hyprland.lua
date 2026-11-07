-- hyprland.lua
-- Only requires; everything lives under conf/. conf/machine is the gitignored
-- per-host symlink to conf/machines/<host>/ (see CLAUDE.md).

require("conf.machine.monitors")
require("conf.env")
require("conf.machine.env")
require("conf.programs")
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

-- Per-scheme overrides written by `theme` (wallust): always misc.background_color,
-- plus decoration.blur from the scheme JSON's optional "hyprland" key.
-- Missing file = values above.
-- Loaded without pcall so mistakes show up in `hyprctl configerrors`.
local theme_overrides = os.getenv("HOME") .. "/.cache/wallust/hypr-theme.lua"
local fh = io.open(theme_overrides)
if fh then
    fh:close()
    dofile(theme_overrides)
end
