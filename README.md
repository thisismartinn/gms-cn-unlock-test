[English](#unlock-cn-gms-english) | [中文说明](#unlock-cn-gms)

# Unlock CN GMS

去除国行系统对 Google Play 服务 (GMS) 的限制：扫描并清理系统中声明 `cn.google.services` 的权限文件，解锁 Quick Share（快速分享）、位置记录 / 地图时间轴等功能。

基于 [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms) 修改。

---

### ⚠️ 风险提示
* 脚本均为明文，刷入前请自行审阅。
* 刷入前请备份数据；因使用本模块导致的任何问题由使用者自行承担。

### ✅ 已测试环境
* Xiaomi HyperOS 4（OS4.0.4.0.XPACNXM，Android 17，国行），KernelSU：Quick Share 可用。
* 其他机型 / 系统理论上可用，但未经验证。

### 🚀 工作原理
1. 安装时扫描 `/system`、`/system_ext`、`/vendor`、`/product`、`/odm`、`/mi_ext` 下的 `etc/permissions` 与 `etc/sysconfig`，以及固定的已知路径（含 ColorOS、Flyme、OriginOS、ZTE 等），找到声明 `cn.google.services` 的文件。
2. 复制这些文件并删除 `cn.google.services` 与 `services_updater` 相关行。
3. 开机时由 `post-fs-data.sh` 用 `mount --bind` 将修改后的文件挂载回原路径。**不依赖 KernelSU 的元模块 / OverlayFS / Magic Mount**。同时仍保留 `system/` 目录供 Magisk 使用。
4. **本模块不包含** GMS 特权权限 XML，也不会自动拉起 Quick Share；这两项需要系统本身已具备。

### 🔍 验证与排查
刷入后**重启**，然后在 Root 管理器中点击模块的 **操作 (Action)** 按钮，或执行：

```
su -c sh /data/adb/modules/com.fei_ke.unlockcngms/action.sh
```

该脚本不会修改系统，只会输出诊断信息并保存到 `/data/local/tmp/unlockcngms-diag.txt`，重点检查：

- `cmd package has-feature cn.google.services` 应为 `false`
- “files that still mention cn.google.services” 应为空
- `mountinfo` 中应能看到本模块的 bind mount

若仍无法使用，请在 Issue 中附上该文件。注意：若同时安装了其他修改相同权限文件的模块，可能互相覆盖，请只保留一个。

随后进入 **Google 设置 → 所有服务 → 已连接的设备和分享**，检查是否出现“快速分享”。

### 🙏 致谢
核心逻辑来自 [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms)。

---
---

# Unlock CN GMS (English)

Removes the CN-ROM restrictions on Google Play services (GMS). It finds permission files that declare `cn.google.services` and strips them, unlocking Quick Share, Location History / Maps Timeline and similar features.

Based on [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms).

---

### ⚠️ Disclaimer
* All scripts are plain text; review them before flashing.
* Back up your data first. You use this module at your own risk.

### ✅ Tested on
* Xiaomi HyperOS 4 (OS4.0.4.0.XPACNXM, Android 17, CN) with KernelSU: Quick Share works.
* Other devices and ROMs should work in theory but are unverified.

### 🚀 How it works
1. At install time it scans `etc/permissions` and `etc/sysconfig` on `/system`, `/system_ext`, `/vendor`, `/product`, `/odm` and `/mi_ext`, plus a list of known OEM paths (ColorOS, Flyme, OriginOS, ZTE, …), for files declaring `cn.google.services`.
2. It copies each file and deletes the `cn.google.services` and `services_updater` lines.
3. On boot, `post-fs-data.sh` bind-mounts the patched files over the originals. **No KernelSU meta-module / OverlayFS / Magic Mount is required.** The `system/` copy is still shipped for Magisk.
4. The module does **not** ship GMS privileged-permission XMLs and does **not** auto-launch Quick Share; the ROM must already provide what Quick Share needs.

### 🔍 Verifying and troubleshooting
After flashing, **reboot**, then press the module's **Action** button in your root manager, or run:

```
su -c sh /data/adb/modules/com.fei_ke.unlockcngms/action.sh
```

It changes nothing; it prints diagnostics and saves them to `/data/local/tmp/unlockcngms-diag.txt`. Check that:

- `cmd package has-feature cn.google.services` is `false`
- "files that still mention cn.google.services" is empty
- `mountinfo` shows this module's bind mounts

If it still doesn't work, attach that file to an issue. Another module that patches the same permission files can override this one, so keep only one active.

Then open **Google Settings → All services → Connected devices & sharing** and look for Quick Share.

### 🙏 Credits
Core logic from [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms).
