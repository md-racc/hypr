-- conf/actions.lua
-- Window actions for conf/keybinds.lua, run in-process. They were scripts
-- round-tripping through `hyprctl -j | jq` and string-built
-- `hyprctl dispatch "<lua>"`, which prints `ok` even for a call it ignores;
-- here a bad argument errors in the Hyprland log.
-- (scripts/window-switcher stays a script: it waits on fuzzel, which would
-- block the compositor if run from here.)

local M = {}

local function windows_on(ws, keep)
    local out = {}
    for _, w in ipairs(hl.get_windows()) do
        if w.mapped and w.workspace and w.workspace.id == ws.id and (not keep or keep(w)) then
            out[#out + 1] = w
        end
    end
    return out
end

local function pos(w)
    return w.at.x .. "," .. w.at.y
end

-- Move the focused window; at the layout's left/right edge (the move left it
-- where it was), carry it to the previous/next workspace instead.
local DIRECTIONS = { l = "left", r = "right", u = "up", d = "down" }
local EDGE_WORKSPACE = { l = "-1", r = "+1" }
function M.move_window(dir)
    local w = hl.get_active_window()
    if not w then return end
    local before = pos(w)
    hl.dispatch(hl.dsp.window.move({ direction = DIRECTIONS[dir] }))
    local after = hl.get_active_window()
    if after and pos(after) == before and EDGE_WORKSPACE[dir] then
        hl.dispatch(hl.dsp.window.move({ workspace = EDGE_WORKSPACE[dir] }))
    end
end

-- Send every window on the active workspace to `target`, then follow them.
function M.send_all(target)
    local ws = hl.get_active_workspace()
    if not ws then return end
    for _, w in ipairs(windows_on(ws)) do
        hl.dispatch(hl.dsp.window.move({
            workspace = tostring(target), window = "address:" .. w.address, silent = true,
        }))
    end
    hl.dispatch(hl.dsp.focus({ workspace = tostring(target) }))
end

-- Even out every dwindle split on the active workspace (ratio 1.0).
-- splitratio acts on the focused window's split, so visit each tiled window,
-- then put focus back.
function M.reset_splits()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local orig = hl.get_active_window()
    for _, w in ipairs(windows_on(ws, function(w) return not w.floating and not w.hidden end)) do
        hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
        hl.dispatch(hl.dsp.layout("splitratio 1.0 exact"))
    end
    if orig then hl.dispatch(hl.dsp.focus({ window = "address:" .. orig.address })) end
end

return M
