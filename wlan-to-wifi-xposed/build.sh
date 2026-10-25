#!/bin/sh
# Builds the signed module APK without Gradle.
#
# Needs (set the variables or edit the defaults):
#   ANDROID_JAR   an android.jar (SDK platform, API 26+)
#   BUILD_TOOLS   an Android SDK build-tools directory (aapt2, zipalign, lib/d8.jar, lib/apksigner.jar)
#   XPOSED_API    classes.jar from io.github.libxposed:api:102.0.0 (the .aar contains it)
#   KEYSTORE      signing keystore; created if missing (alias "module", password "module").
#                 Keep it: updates only install over the same signature.
# Also needs a JDK (javac, keytool) and zip.
set -e

HERE=$(cd "$(dirname "$0")" && pwd)
: "${ANDROID_JAR:?set ANDROID_JAR}" "${BUILD_TOOLS:?set BUILD_TOOLS}" "${XPOSED_API:?set XPOSED_API}"
KEYSTORE=${KEYSTORE:-$HERE/build/module.jks}
OUT=${OUT:-$HERE/build/wlan-to-wifi-xposed.apk}
W=$HERE/build/work

rm -rf "$W" && mkdir -p "$W/classes" "$W/dex" "$W/apk"

javac --release 8 -Xlint:-options -cp "$ANDROID_JAR:$XPOSED_API" -d "$W/classes" \
    $(find "$HERE/src" -name '*.java')
java -cp "$BUILD_TOOLS/lib/d8.jar" com.android.tools.r8.D8 --min-api 26 --lib "$ANDROID_JAR" \
    --output "$W/dex" $(find "$W/classes" -name '*.class')

"$BUILD_TOOLS/aapt2" compile --dir "$HERE/res" -o "$W/res.zip"
"$BUILD_TOOLS/aapt2" link -I "$ANDROID_JAR" --manifest "$HERE/AndroidManifest.xml" \
    --min-sdk-version 26 --target-sdk-version 34 -o "$W/base.apk" "$W/res.zip"

# classes.dex and the Xposed metadata go into the APK root
cp "$W/dex/classes.dex" "$W/apk/"
cp -r "$HERE/resources/META-INF" "$W/apk/"
(cd "$W/apk" && zip -qr "$W/base.apk" classes.dex META-INF)

"$BUILD_TOOLS/zipalign" -p -f 4 "$W/base.apk" "$W/aligned.apk"
if [ ! -f "$KEYSTORE" ]; then
    mkdir -p "$(dirname "$KEYSTORE")"
    keytool -genkeypair -keystore "$KEYSTORE" -storepass module -keypass module -alias module \
        -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=wlan-to-wifi"
fi
mkdir -p "$(dirname "$OUT")"
"$BUILD_TOOLS/apksigner" sign --ks "$KEYSTORE" --ks-pass pass:module --key-pass pass:module \
    --out "$OUT" "$W/aligned.apk"
"$BUILD_TOOLS/apksigner" verify --print-certs "$OUT" | head -3
echo "built $OUT"
