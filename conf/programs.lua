-- conf/programs.lua
-- Default apps for binds (shared by both machines).
return {
    terminal    = "kitty -e /bin/zsh",
    fileManager = "kitty ranger",
    taskmanager = "kitty btop",
    browser     = "firefox",
    notes       = "obsidian --ozone-platform=wayland",
    ide         = "kitty nvim",
}
