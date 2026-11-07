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

-- Qt apps (OBS, Tux Manager, Nextcloud) take palette + icons from the GTK theme (wallust's), via Qt's
-- gtk3 platform theme plugin (qt6-base); unset, they used Qt's own Fusion look
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- Hardware video decode (VA-API) on the RTX 2060 through nvidia-vaapi-driver
-- (pacman: libva-nvidia-driver). libva would guess the driver from the DRM
-- device too; set it so nothing picks another one. Firefox's RDD sandbox blocks
-- the driver's /dev/nvidia* access, hence MOZ_DISABLE_RDD_SANDBOX (zion only:
-- roci's Intel VA-API works inside the sandbox). The Firefox prefs that go with
-- this are in wallust templates/firefox-user.js.
-- Check: `vainfo`, about:support "HARDWARE_VIDEO_DECODING", `nvidia-smi dmon -s u` (dec %).
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
