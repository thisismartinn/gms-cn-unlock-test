#!/system/bin/sh

PKG=com.google.android.projection.gearhead
DEST=$MODPATH/system/product/priv-app/GearHead
XML_DIR=$MODPATH/system/product/etc/permissions
XML=$XML_DIR/privapp-permissions-gearhead.xml

apks=$(pm path $PKG 2>/dev/null | sed 's/^package://')
[ -n "$apks" ] || abort "Android Auto ($PKG) is not installed. Install it from the Play Store first."

if pm list packages -s 2>/dev/null | grep -qx "package:$PKG"; then
    abort "Android Auto is already a system app, nothing to do."
fi

mkdir -p "$DEST" "$XML_DIR"
for apk in $apks; do
    ui_print "copy $(basename "$apk")"
    cp -f "$apk" "$DEST/$(basename "$apk")" || abort "Failed to copy $apk"
done

# Whitelist every permission the installed app requests. A privileged app that
# requests a privileged permission missing from the whitelist can stop boot, so
# build the list from the real APK instead of hard-coding it.
dumpsys package $PKG > "$TMPDIR/gearhead-dump.txt"
: > "$TMPDIR/gearhead-perms.txt"
in=0
hdr=0
while IFS= read -r line; do
    stripped="${line#"${line%%[![:space:]]*}"}"
    indent=$((${#line} - ${#stripped}))
    if [ $in = 1 ]; then
        if [ $indent -le $hdr ]; then
            in=0
        else
            echo "${stripped%%[: ]*}" >> "$TMPDIR/gearhead-perms.txt"
        fi
    fi
    case "$stripped" in
        "requested permissions:"*) in=1; hdr=$indent ;;
    esac
done < "$TMPDIR/gearhead-dump.txt"

grep -E '^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$' "$TMPDIR/gearhead-perms.txt" | sort -u > "$TMPDIR/gearhead-perms-clean.txt"
count=$(wc -l < "$TMPDIR/gearhead-perms-clean.txt")
[ "$count" -ge 5 ] || abort "Could only read $count permissions from Android Auto; refusing to continue (a bad whitelist can break boot)."

{
    echo '<?xml version="1.0" encoding="utf-8"?>'
    echo '<permissions>'
    echo "    <privapp-permissions package=\"$PKG\">"
    while IFS= read -r perm; do
        echo "        <permission name=\"$perm\"/>"
    done < "$TMPDIR/gearhead-perms-clean.txt"
    echo '    </privapp-permissions>'
    echo '</permissions>'
} > "$XML"
ui_print "whitelisted $count permissions"

set_perm_recursive "$MODPATH/system" 0 0 0755 0644 u:object_r:system_file:s0

ui_print ""
ui_print "Reboot to apply. Reinstall this module after Android Auto updates."
if [ "$KSU" = true ]; then
    ui_print "KernelSU: a metamodule (meta-overlayfs / mountify) must be installed,"
    ui_print "otherwise nothing is mounted and error 22 stays."
fi
