hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_BACKEND", "wayland")   -- no x11 fallback: XWayland is off
hl.env("GSK_RENDERER", "gl")

-- File dialogs through the xdg portal (→ termfilechooser/ranger) instead of GTK's own
hl.env("GTK_USE_PORTAL", "1")   -- GTK3
hl.env("GDK_DEBUG", "portals")  -- GTK4

-- Qt apps (OBS, Tux Manager, Nextcloud) take palette + icons from the GTK theme (wallust's), via Qt's
-- gtk3 platform theme plugin (qt6-base); unset, they used Qt's own Fusion look
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
