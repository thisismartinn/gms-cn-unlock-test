#!/system/bin/sh
# Checks whether the Wi-Fi label overlays are mounted and applied. Changes nothing.

OUT=/data/local/tmp/unlockcngms-wifilabel-diag.txt

{
echo "== locale =="
echo "ro.product.locale=$(getprop ro.product.locale)"
echo "persist.sys.locale=$(getprop persist.sys.locale)"

echo; echo "== overlay files visible in the system? =="
ls -l /system_ext/overlay 2>&1 | grep -i WifiLabel

echo; echo "== registered overlays (want [x] / enabled) =="
cmd overlay list 2>&1 | grep -iE -B1 'wifilabel|unlockcngms'

echo; echo "== what the apps resolve now (want Wi-Fi) =="
cmd overlay lookup com.android.settings com.android.settings:string/app_wifi 2>&1
cmd overlay lookup com.android.systemui com.android.systemui:string/quick_settings_wifi_label 2>&1

echo; echo "== log hints =="
logcat -d 2>/dev/null | grep -iE 'idmap|OverlayManager|wifilabel' | tail -30
} > "$OUT" 2>&1

cat "$OUT"
echo
echo "Saved to $OUT"
