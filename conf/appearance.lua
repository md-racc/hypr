-- conf/appearance.lua
-- Converted from conf/appearance.conf. See docs/superpowers/plans/2026-08-27-hyprland-lua-migration.md.

hl.config({
    general = {
        gaps_in  = 1,
        gaps_out = 2,

        border_size = 1,

        col = {
            active_border   = "rgba(0,66,255,00)",
            inactive_border = "rgba(0,66,255,0)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 1,
        rounding_power = 5,

        shadow = {
            enabled      = false,
            range        = 30,
            render_power = 3,
            color        = "rgb(FFFFFF)",
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            vibrancy          = 0.15,
            vibrancy_darkness = 1.0,
            ignore_opacity    = true,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}   } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",           enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",           enabled = true, speed = 3.77, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",          enabled = true, speed = 3.35, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4.0,  bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1.25, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 1.21, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.02, bezier = "easeOutQuint" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2.12, bezier = "easeOutQuint" })
hl.animation({ leaf = "layers",           enabled = true, speed = 2.67, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 2.8,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.05, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 1.25, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 0.97, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 1.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesIn",     enabled = true, speed = 1.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "workspacesOut",    enabled = true, speed = 1.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.1,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 4.9,  bezier = "quick" })

hl.config({
    dwindle = {
        -- required for togglesplit/rotatesplit to have any effect — see CLAUDE.md gotchas
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        enable_swallow          = true,
        swallow_regex           = "^(kitty)$",
        -- wake displays from manual dpms-off (away mode) — key-only so desk bumps don't wake
        key_press_enables_dpms  = true,
    },
})
