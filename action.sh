#!/system/bin/sh
# Run from the root manager's Action button. Collects evidence on why Quick
# Share / GMS features are still blocked and saves it to $OUT.

OUT=/data/local/tmp/unlockcngms-diag.txt
GMS=com.google.android.gms

{
echo "== device =="
for p in ro.product.manufacturer ro.product.model ro.build.version.release \
         ro.mi.os.version.name ro.mi.os.version.incremental ro.miui.region; do
    echo "$p=$(getprop $p)"
done

echo; echo "== is the CN flag still declared? (want: false) =="
cmd package has-feature cn.google.services 2>&1
pm list features 2>/dev/null | grep -iE 'cn\.|google'

echo; echo "== files that still mention cn.google.services (want: none) =="
for dir in /system /system_ext /vendor /product /odm /mi_ext; do
    grep -rls 'cn.google.services' $dir/etc/permissions $dir/etc/sysconfig 2>/dev/null
done

echo; echo "== module-modified files =="
find "${0%/*}" -name '*.xml' 2>/dev/null

echo; echo "== GMS install =="
pm path $GMS
dumpsys package $GMS | grep -E 'versionName|codePath|privateFlags|pkgFlags'
pm list packages -d | grep -i google

echo; echo "== google privapp permission files =="
ls /product/etc/permissions /system_ext/etc/permissions 2>/dev/null | grep -i google

echo; echo "== Quick Share / Nearby components =="
dumpsys package $GMS | grep -iE 'nearby\.sharing|quickshare' | sort -u | head -40

echo; echo "== GMS permissions not granted =="
dumpsys package $GMS | grep 'granted=false' | head -40

echo; echo "== logcat hints =="
logcat -d -b main,system 2>/dev/null | grep -iE 'privapp|not in privileged|nearby|quickshare|sharing' | tail -60
} > "$OUT" 2>&1

cat "$OUT"
echo
echo "Saved to $OUT"
