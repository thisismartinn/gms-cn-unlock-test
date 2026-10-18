#!/system/bin/sh
# Shows the locale properties and any Wi-Fi label overlay. Changes nothing.

echo "ro.product.locale=$(getprop ro.product.locale)  (want en-US)"
echo "persist.sys.locale=$(getprop persist.sys.locale)"
echo
cmd overlay list 2>&1 | grep -iE 'wifi|wlan|unlockcngms'
