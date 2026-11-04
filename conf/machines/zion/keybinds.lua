local programs = require("conf.machine.programs")

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
