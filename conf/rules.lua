-- conf/rules.lua
-- Converted from conf/rules.conf.

-- Gnome apps
hl.window_rule({ name = "gnome-float", match = { class = "org.gnome.*" }, float = true })

hl.window_rule({
    name  = "calculator-position",
    match = { class = "org.gnome.Calculator" },
    size  = "400 620",
    move  = "6 453",
})

hl.window_rule({
    name  = "calendar-position",
    match = { class = "org.gnome.Calendar" },
    size  = "360 600",
    move  = "6 474",
})

-- Media
hl.window_rule({
    name   = "mpv-float",
    match  = { class = "mpv" },
    float  = true,
    size   = "1280 720",
    center = true,
})

hl.window_rule({ name = "spotify-tile", match = { class = "^(Spotify)$" }, tile = true })

-- System tools
hl.window_rule({ name = "resources-float", match = { class = "net.nokyan.Resources" }, float = true })
hl.window_rule({ name = "portal-float",    match = { class = "xdg-desktop-portal-gtk" }, float = true })

hl.window_rule({
    name   = "termfilechooser",
    match  = { class = "termfilechooser" },
    float  = true,
    size   = "1100 650",
    center = true,
})

-- File manager
hl.window_rule({ name = "nemo-float", match = { class = "nemo" }, float = true })

-- Scratchpad
hl.window_rule({
    name      = "scratchpad-float",
    match     = { class = "scratchpad" },
    float     = true,
    size      = "900 600",
    center    = true,
    workspace = "special silent",
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

-- screenie (area screenshot picker) overlay: appear instantly, like slurp
hl.layer_rule({ name = "screenie", match = { namespace = "^screenie$" }, no_anim = true })

-- screenie's pin (P): the box floats over everything, on every workspace
hl.window_rule({ name = "screenie-pin", match = { class = "^screenie-pin$" }, float = true, pin = true })
