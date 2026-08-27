local programs = require("conf.machine.programs")

hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("SUPER + P", hl.dsp.exec_cmd(programs.taskmanager))
hl.bind("SUPER + T", hl.dsp.exec_cmd(programs.ide))
hl.bind("SUPER + O", hl.dsp.exec_cmd(programs.notes))
hl.bind("SUPER + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/netmenu"))

hl.bind("SUPER + Z", hl.dsp.exec_cmd("eww open bar --toggle"))

-- Keyboard backlight (tpacpi::kbd_backlight, max 2)
hl.bind("ALT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d tpacpi::kbd_backlight set +1"), { locked = true })
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d tpacpi::kbd_backlight set 1-"), { locked = true })
