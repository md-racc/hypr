hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("GSK_RENDERER", "gl")

-- File dialogs through the xdg portal (→ termfilechooser/ranger) instead of GTK's own
hl.env("GTK_USE_PORTAL", "1")   -- GTK3
hl.env("GDK_DEBUG", "portals")  -- GTK4
