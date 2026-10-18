#!/system/bin/sh
# Reports whether Android Auto is now a system app. Changes nothing.

OUT=/data/local/tmp/unlockcngms-androidauto-diag.txt
PKG=com.google.android.projection.gearhead

{
echo "== flags (want SYSTEM and PRIVILEGED) =="
dumpsys package $PKG | grep -E 'codePath|versionName|pkgFlags|privateFlags'

echo; echo "== mounted files =="
ls -l /product/priv-app/GearHead 2>&1
ls -l /product/etc/permissions/privapp-permissions-gearhead.xml 2>&1

echo; echo "== module state =="
ls -a "${0%/*}" | grep -E '^(disable|boot_pending)$'

echo; echo "== log hints =="
logcat -d -b main,system 2>/dev/null | grep -iE 'privileged permission|not in privapp|gearhead' | tail -40
} > "$OUT" 2>&1

cat "$OUT"
echo
echo "Saved to $OUT"
