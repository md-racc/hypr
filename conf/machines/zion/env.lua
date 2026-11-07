-- Hardware video decode (VA-API) on the RTX 2060 through nvidia-vaapi-driver
-- (pacman: libva-nvidia-driver). libva would guess the driver from the DRM
-- device too; set it so nothing picks another one. Firefox's RDD sandbox blocks
-- the driver's /dev/nvidia* access, hence MOZ_DISABLE_RDD_SANDBOX (zion only:
-- roci's Intel VA-API works inside the sandbox). The Firefox prefs that go with
-- this are in wallust templates/firefox-user.js.
-- Check: `vainfo`, about:support "HARDWARE_VIDEO_DECODING", `nvidia-smi dmon -s u` (dec %).
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
