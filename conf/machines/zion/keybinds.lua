local programs = require("conf.programs")

hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("SUPER + P", hl.dsp.exec_cmd(programs.taskmanager))
hl.bind("SUPER + T", hl.dsp.exec_cmd(programs.ide))
hl.bind("SUPER + O", hl.dsp.exec_cmd(programs.notes))

-- again: keyboard macro record/replay (gitea.lan/mdracc/again). --control-chord names the
-- invoking shortcut so again keeps it out of the macro. Devices are autodetected (every keyboard
-- the uaccess rule grants). Playback runs idle pauses at 2x, each capped at 1 s; key holds stay exact.
local AGAIN = "~/.local/bin/again"
hl.bind("SUPER + SHIFT + period", hl.dsp.exec_cmd(AGAIN .. " record --toggle --control-chord SUPER+SHIFT+KEY_DOT"))
hl.bind("SUPER + period",         hl.dsp.exec_cmd(AGAIN .. " play --speed 2 --max-idle 1000 --control-chord SUPER+KEY_DOT"))
hl.bind("SUPER + Escape",         hl.dsp.exec_cmd(AGAIN .. " cancel"))

-- Monitor brightness over DDC/CI (zion's keyboards have no brightness keys): SUPER+F5/F6, as ly's
-- brightness_down_key/brightness_up_key. Clear of the lock screen's F1-F4 power keys.
hl.bind("SUPER + F6", hl.dsp.exec_cmd("~/.config/hypr/scripts/osd bright up"),   { locked = true })
hl.bind("SUPER + F5", hl.dsp.exec_cmd("~/.config/hypr/scripts/osd bright down"), { locked = true })
