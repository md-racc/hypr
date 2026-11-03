local programs = require("conf.machine.programs")

hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("SUPER + P", hl.dsp.exec_cmd(programs.taskmanager))
hl.bind("SUPER + T", hl.dsp.exec_cmd(programs.ide))
hl.bind("SUPER + O", hl.dsp.exec_cmd(programs.notes))

-- again: keyboard macro record/replay (gitea.lan/mdracc/again). --control-chord names the
-- invoking shortcut so again keeps it out of the macro. Both Keychron interfaces are listed
-- explicitly: discovery would also open the G305's keyboard interface.
local AGAIN = "~/.local/bin/again"
local AGAIN_DEVICES = " --device /dev/input/by-id/usb-Keychron_Keychron_K3_Max-event-kbd"
    .. " --device /dev/input/by-id/usb-Keychron_Keychron_K3_Max-if02-event-kbd"
hl.bind("SUPER + SHIFT + period", hl.dsp.exec_cmd(AGAIN .. " record --toggle --control-chord SUPER+SHIFT+KEY_DOT" .. AGAIN_DEVICES))
hl.bind("SUPER + period",         hl.dsp.exec_cmd(AGAIN .. " play --control-chord SUPER+KEY_DOT" .. AGAIN_DEVICES))
hl.bind("SUPER + Escape",         hl.dsp.exec_cmd(AGAIN .. " cancel"))
