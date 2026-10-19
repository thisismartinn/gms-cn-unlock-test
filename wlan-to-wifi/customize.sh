#!/system/bin/sh

set_perm_recursive "$MODPATH/system" 0 0 0755 0644 u:object_r:system_file:s0

ui_print "Overlays: Settings, System UI and Phone (WLAN -> Wi-Fi, English only)"
ui_print "Reboot to apply."
if [ "$KSU" = true ]; then
    ui_print "KernelSU: a metamodule (meta-overlayfs / mountify) must be installed,"
    ui_print "otherwise the overlay files are never mounted."
    ui_print "Also turn off \"Unmount modules\" in KernelSU Manager for Settings,"
    ui_print "System UI and Phone, or those apps cannot open the overlay files."
fi
