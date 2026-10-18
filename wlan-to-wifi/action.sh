#!/system/bin/sh
# Shows the locale properties and any Wi-Fi label overlay. Changes nothing.

echo "ro.product.locale=$(getprop ro.product.locale)  (stock CN ROM: zh-CN)"
echo "persist.sys.locale=$(getprop persist.sys.locale)"
echo
cmd overlay list 2>&1 | grep -iE 'wifi|wlan|unlockcngms'
