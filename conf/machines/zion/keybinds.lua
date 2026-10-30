local programs = require("conf.machine.programs")

hl.bind("SUPER + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind("SUPER + P", hl.dsp.exec_cmd(programs.taskmanager))
hl.bind("SUPER + T", hl.dsp.exec_cmd(programs.ide))
hl.bind("SUPER + O", hl.dsp.exec_cmd(programs.notes))
