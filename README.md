[English README](#gms-nexus-proxy-english) | [中文说明](#gms-nexus-proxy)

# GMS Nexus Proxy

**GMS Nexus Proxy** 是一个一体化 GMS 补全与解锁 CN 限制的系统级代理模块。内置解锁逻辑与全量特权许可文件，彻底解决国行系统及本土化 ROM 上 Google 快速分享（Quick Share）、FCM 权限缺失及时间轴/位置报告被封锁的问题。

---

### ⚠️ 免责与风险提示
* **自行承担风险**：本模块由 AI 辅助与作者联合开发，作者非专业安卓底层开发者。
* **明文透明**：所有 Shell 脚本与 XML 配置文件均为 **明文公开、未做任何加密**，刷入前可自行审阅。
* **风险自负**：刷入前请务必备份系统/数据，因刷入、配置不当或系统兼容性导致的任何设备异常、卡屏、死机等问题，使用者需自行承担全部风险与责任。

---

### 📱 系统要求与兼容性

- **分区规范要求**：必须具备 `/product` 分区结构，全量特权配置文件将挂载至 `/product/etc/permissions/` 目录之下。
- **理论兼容版本**：理论支持 **Android 10 至 Android 17** 所有遵循标准 `/product` 分区的国行及第三方本土化 ROM。
- **环境依赖**：特权 XML 文件的生效需配合 **元模块/挂载模块 (OverlayFS / Magic Mount)** 环境使用。

---

### 🚀 核心特性

1. **一体化解锁 CN 限制（基于 unlock-cn-gms v3.8）**
   模块内置自动化扫描逻辑，自动查找并清理系统中声明 `cn.google.services` 的限制标签（彻底移除国行 GMS 封锁，解锁 Google 位置记录与地图时间轴限制）。
   
   **自动处理及替换路径列表：**
   - `/system/etc/permissions/services.cn.google.xml`
   - `/system/etc/permissions/com.oppo.features.cn_google.xml`
   - `/vendor/etc/permissions/services.cn.google.xml`
   - `/product/etc/permissions/services.cn.google.xml`
   - `/product/etc/permissions/cn.google.services.xml`
   - `/product/etc/sysconfig/cn_feature.xml`
   - `/odm/etc/permissions/com.gnss.bds_preference.xml`
   - `/my_bigball/etc/permissions/oplus_google_cn_gms_features.xml`
   - `/my_product/etc/permissions/oplus_google_cn_gms_features.xml`
   - `/my_heytap/etc/permissions/my_heytap_cn_gms_features.xml`

2. **GMS 特权全量补全**
   内置完整 GMS 特权许可 XML，全量补齐并标准化挂载至 `/product/etc/permissions/` 路径。

3. **Quick Share 智能唤醒与状态验证**
   针对部分国产系统隐藏 Quick Share 入口的问题，模块内置唤醒逻辑与状态验证：
   - **首次开机/更新后**：进入桌面约 5 秒，系统后台会自动强制调起快速分享页面并保持显示在前台，完成组件的挂载激活。
   - **验证方法**：若开机未自动触发，可在 Root 管理器中点击模块右侧的 **【操作 / 执行】** 按钮手动调起。调起后，进入 **Google 设置 → 所有服务 → 已连接的设备和分享**，若能正常看见并进入“快速分享”设置页面且功能开关可用，即代表挂载成功。

---

### 🙏 致谢与开源声明

本模块的核心解锁 CN 限制逻辑基于 [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms) 项目重构与扩展，特此感谢原作者的卓越贡献。

本项目遵循开源社区“代码明文、尊重原创”的原则。如有任何版权或许可相关建议，欢迎提交 Issue。

---
---

# GMS Nexus Proxy (English)

**GMS Nexus Proxy** is an all-in-one system proxy module designed for GMS completion and unbinding CN restrictions. It integrates unlocking logic with full privileged permission XML files, completely resolving issues on CN firmware or regional ROMs such as missing Quick Share, FCM privilege restrictions, and blocked Google Location History / Maps Timeline.

---

### ⚠️ Disclaimer & Risk Warning
* **Use at Your Own Risk**: This module is co-developed by the author with AI assistance. The author is not a professional Android low-level developer.
* **Transparent Code**: All Shell scripts and XML configuration files are **open source in plain text with no encryption**, allowing full review prior to flashing.
* **Liability Notice**: Please backup your system/data before flashing. The user assumes all responsibilities and risks for any device anomalies, bootloops, or system crashes caused by using or misconfiguring this module.

---

### 📱 System Requirements & Compatibility

- **Partition Structure Requirement**: The system must feature a `/product` partition. All privileged permission files will be mounted under `/product/etc/permissions/`.
- **Theoretical Compatibility**: Theoretically supports **Android 10 through Android 17** on any CN stock or custom OEM ROMs adhering to standard `/product` partition specifications.
- **Environment Dependency**: Mounting privileged XML files requires a **Meta-module / Mount Module (OverlayFS / Magic Mount)** environment.

---

### 🚀 Key Features

1. **Integrated CN Restriction Unlocking (Based on unlock-cn-gms v3.8)**
   Built-in automated scanning logic that identifies and cleans `cn.google.services` restriction flags within system permissions (completely removing CN GMS blockades, unlocking Google Location History and Maps Timeline restrictions).

   **Automatically Processed & Replaced Paths:**
   - `/system/etc/permissions/services.cn.google.xml`
   - `/system/etc/permissions/com.oppo.features.cn_google.xml`
   - `/vendor/etc/permissions/services.cn.google.xml`
   - `/product/etc/permissions/services.cn.google.xml`
   - `/product/etc/permissions/cn.google.services.xml`
   - `/product/etc/sysconfig/cn_feature.xml`
   - `/odm/etc/permissions/com.gnss.bds_preference.xml`
   - `/my_bigball/etc/permissions/oplus_google_cn_gms_features.xml`
   - `/my_product/etc/permissions/oplus_google_cn_gms_features.xml`
   - `/my_heytap/etc/permissions/my_heytap_cn_gms_features.xml`

2. **Full GMS Privileged Permissions Completion**
   Includes complete GMS privileged permission XMLs, fully mounted to the modern Android standard path `/product/etc/permissions/`.

3. **Quick Share Smart Trigger & Status Verification**
   Resolves the issue where Quick Share is hidden on certain OEM systems:
   - **First Boot / Post-Update**: Approx. 5 seconds after reaching the desktop, the system automatically launches the Quick Share interface and keeps it in the foreground to complete component activation.
   - **Verification Method**: If not triggered automatically, click the **[Action / Execute]** button on the right side of the module in your Root Manager. Then go to **Google Settings → All Services → Connected devices & sharing**. If Quick Share is visible and functional, the module is successfully mounted.

---

### 🙏 Credits & Open Source Declaration

The core CN unlocking logic of this module is based on and refactored from [fei-ke/unlock-cn-gms](https://github.com/fei-ke/unlock-cn-gms). Special thanks to the original author for the outstanding work.

This project follows the principles of open-source transparency and respect for original creators. All modifications remain open source. If you have any copyright or licensing suggestions, feel free to submit an Issue.
