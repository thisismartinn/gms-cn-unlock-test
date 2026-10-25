# WLAN to Wi-Fi (Xposed)

An Xposed module (libxposed API 101/102) that shows "Wi-Fi" instead of "WLAN" in the apps you enable it for. It is the no-mount alternative to the `wlan-to-wifi/` overlay module: no metamodule and no "Unmount modules" changes, and any app can be covered by adding it to the scope.

## How it works

It hooks the places apps read strings from their resources (`Resources.getText/getString/getQuantityText/getQuantityString/getTextArray/getStringArray` and `TypedArray.getText/getString/getTextArray`, plus `MiuiResources` when the ROM has it) and replaces `WLAN` with `Wi-Fi` in what they return. Spans (bold, links) are kept.

`TextView.setText` is deliberately not hooked, so text that is not a resource, such as a network named `WLAN-1234`, is left alone. Formatted lookups go through `getString(int)`, so their arguments are never rewritten.

Errors inside the hooks are caught by the framework (`exceptionMode=protective`), so a bug here falls back to the original text instead of crashing the app.

## Install

1. Install the APK and enable it in Vector / LSPosed.
2. Recommended scope: Settings, System UI, Phone (`com.android.settings`, `com.android.systemui`, `com.android.phone`). Add other apps (Security Center, Cloud, ...) the same way.
3. Restart the scoped apps (`am force-stop <package>`) or reboot. System UI restarts itself with `killall com.android.systemui`.

## Verify

```
logcat -d | grep WlanToWifi
```

Each scoped process should log `hooked N methods in <package>` (about 10). No line means the module was not injected into that process; check the scope and that the framework supports API 101 or newer.

Only English is useful: the module replaces the literal text `WLAN` in any language, but other languages mostly use their own wording.

## Build

`build.sh` builds and signs the APK without Gradle. See its header for the inputs (`android.jar`, SDK build-tools, `classes.jar` from `io.github.libxposed:api:102.0.0`, a JDK). Keep the keystore: updates only install over the same signature.
