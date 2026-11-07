-- conf/rules.lua
-- Shared window and layer rules.

-- Gnome apps
hl.window_rule({ name = "gnome-float", match = { class = "org.gnome.*" }, float = true })

-- Media
hl.window_rule({
    name   = "mpv-float",
    match  = { class = "mpv" },
    float  = true,
    size   = "1280 720",
    center = true,
})

-- System tools
hl.window_rule({ name = "portal-float",    match = { class = "xdg-desktop-portal-gtk" }, float = true })

hl.window_rule({
    name   = "termfilechooser",
    match  = { class = "termfilechooser" },
    float  = true,
    size   = "1100 650",
    center = true,
})

-- Browser extensions
hl.window_rule({
    name  = "bitwarden-popup",
    match = { title = "Extension: \\(Bitwarden Password Manager\\).*" },
    float = true,
    size  = "463 606",
})

-- Qalculate
hl.window_rule({
    name   = "qalculate-float",
    match  = { class = "qalculate-gtk" },
    float  = true,
    size   = "826 557",
    center = true,
})

-- Global rules
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- fuzzel (namespace "launcher"): blur what's behind its translucent background
hl.layer_rule({ name = "fuzzel", match = { namespace = "^launcher$" }, blur = true })
-- fnott (namespace "notifications"): same
hl.layer_rule({ name = "fnott", match = { namespace = "^notifications$" }, blur = true })

-- screenie (area screenshot picker) overlay: appear instantly, like slurp
hl.layer_rule({ name = "screenie", match = { namespace = "^screenie$" }, no_anim = true })

-- screenie's pin (P): the box floats over everything, on every workspace
hl.window_rule({ name = "screenie-pin", match = { class = "^screenie-pin$" }, float = true, pin = true })
