# Unlock CN GMS

Removes the CN-ROM restrictions on Google Play services (GMS). The module finds permission files that declare `cn.google.services` and strips that declaration, unlocking Quick Share, Location History / Maps Timeline and similar features.

Based on [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms).

## Disclaimer

- All scripts are plain text; review them before flashing.
- Back up your data first. You use this module at your own risk.

## Tested on

- Xiaomi HyperOS 4 (OS4.0.4.0.XPACNXM, Android 17, CN region) with KernelSU: Quick Share works.
- Other devices and ROMs should work in theory but are unverified.

## How it works

1. At install time the module scans `etc/permissions` and `etc/sysconfig` on `/system`, `/system_ext`, `/vendor`, `/product`, `/odm` and `/mi_ext`, plus a list of known OEM paths (ColorOS, Flyme, OriginOS, ZTE, ...), for files declaring `cn.google.services`.
2. It copies each file and deletes the `cn.google.services` and `services_updater` lines.
3. On boot, `post-fs-data.sh` bind-mounts the patched files over the originals. No KernelSU meta-module, OverlayFS or Magic Mount is required. A `system/` copy is still shipped for Magisk.

What it does **not** do: it does not ship GMS privileged-permission XMLs and does not launch Quick Share for you. The ROM must already provide what Quick Share needs.

## Verify and troubleshoot

After flashing, **reboot**, then press the module's **Action** button in your root manager, or run:

```
su -c sh /data/adb/modules/com.fei_ke.unlockcngms/action.sh
```

The script changes nothing. It prints diagnostics and saves them to `/data/local/tmp/unlockcngms-diag.txt`. Check that:

- `cmd package has-feature cn.google.services` prints `false`
- "files that still mention cn.google.services" is empty
- `mountinfo` shows this module's bind mounts

Then open **Google Settings > All services > Connected devices & sharing** and look for Quick Share.

If it still doesn't work, attach the diagnostics file to an issue.

### Known issues

- Another module that patches the same permission files can override this one. Keep only one active.
- The Quick Share tile may not show up in HyperOS's control center, even though GMS provides it. Quick Share is still reachable from the share sheet and the Settings page.

## Android Auto as a system app (experimental, separate module)

Android Auto fails with "communication error 22 - not preinstalled" when it is a normal user-installed app. The `android-auto/` folder builds a **separate** module that installs the Play Store copy as a privileged system app, so it can be removed independently of the CN fix.

- Install Android Auto from the Play Store first, then flash `*-android-auto.zip`.
- It needs a mount provider on KernelSU (a metamodule such as meta-overlayfs or mountify), because it adds a new directory under `/product/priv-app`.
- The privileged-permission whitelist is built at install time from the permissions your installed Android Auto actually requests. Reinstall the module after Android Auto updates.
- If a boot never completes, the module disables itself on the next boot. You can also disable it from KernelSU safe mode.
- Untested beyond a mock install; back up first. Use its Action button to check whether Android Auto now shows the `SYSTEM` flag.

## Credits

Core logic from [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms).
