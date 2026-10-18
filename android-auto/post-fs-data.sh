#!/system/bin/sh
MODDIR=${0%/*}

# If the previous boot never reached boot_completed, assume this module broke
# it and switch it off for the next boot.
if [ -f "$MODDIR/boot_pending" ]; then
    touch "$MODDIR/disable"
    rm -f "$MODDIR/boot_pending"
    exit 0
fi
touch "$MODDIR/boot_pending"
