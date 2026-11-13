-- Hardware video decode (VA-API) on the RTX 2060 through nvidia-vaapi-driver
-- (pacman: libva-nvidia-driver). libva would guess the driver from the DRM
-- device too; set it so nothing picks another one. Firefox's RDD sandbox blocks
-- the driver's /dev/nvidia* access, hence MOZ_DISABLE_RDD_SANDBOX (zion only:
-- roci's Intel VA-API works inside the sandbox). The Firefox prefs that go with
-- this are in wallust templates/firefox-user.js.
-- Check: `vainfo`, about:support "HARDWARE_VIDEO_DECODING", `nvidia-smi dmon -s u` (dec %).
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")

-- No explicit sync for NVIDIA EGL clients (Firefox, kitty: anything launched
-- from Hyprland). With 615.78.08 + egl-wayland2 1.0.2 + Hyprland 0.57, EGL
-- clients wedge in eglSwapBuffers after resume or unlock and the whole app
-- stops responding (zion, 2026-11-07..12; resume also logs "Failed to register
-- auto-value-update ... sync FD semaphore surface"). Upstream:
-- NVIDIA/egl-wayland2#59 (same stack: 0/12 hangs with this set). Clients fall
-- back to implicit sync. Check: `WAYLAND_DEBUG=client kitty -e true 2>&1 |
-- grep -c set_acquire_point` prints 0. Drop it once egl-wayland2 fixes #59.
hl.env("__NV_DISABLE_EXPLICIT_SYNC", "1")
