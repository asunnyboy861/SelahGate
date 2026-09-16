# SelahGate — 配置文档

生成时间：2026-09-16

---

## 一、⚠️ 手动配置（增强功能 — 不配置不影响基本使用）

> **重要说明**：以下配置项均为**上架必需的运营配置**。App 本身下载后即可正常使用所有核心功能（免费层完整可用）。但不完成以下配置，**付费与审核环节无法通过**。

### 🔵 IAP StoreKit 产品创建（订阅上架前必需）

**影响功能**：不创建 IAP 产品则付费墙无产品可买，订阅收入为 0（免费层功能不受影响，代码有优雅降级：产品加载失败时付费墙显示友好提示）

**配置步骤**：
1. 打开 [App Store Connect](https://appstoreconnect.apple.com) → 我的 App → 创建 SelahGate（Bundle ID: `com.zzoutuo.SelahGate`）
2. 进入 **Features** → **In-App Purchases** → 点击 **"+"**
3. 先创建订阅组 **"SelahGate Pro"**，然后创建以下产品：

| 产品 | Reference Name | Product ID | 价格 | 类型 |
|------|---------------|-----------|------|------|
| 月付 | SelahGate Pro Monthly | `com.zzoutuo.SelahGate.pro.monthly` | $4.99/月 | 自动续期订阅 |
| 年付 | SelahGate Pro Annual | `com.zzoutuo.SelahGate.pro.yearly` | $29.99/年（7天免费试用） | 自动续期订阅 |
| 终身 | SelahGate Lifetime | `com.zzoutuo.SelahGate.pro.lifetime` | $69.99 买断 | 非消耗型 |

4. Display Name / Description 从 `price.md` 复制（已验证字符限制：名称≤35字符、描述≤55字符）
5. 年付产品需在订阅组中配置 **7 天免费试用**（Offer Type: Free Trial，Duration: 7 days）
6. ⚠️ 本地测试：在 Xcode 中 File → New → File → StoreKit Configuration File，创建同名三个产品（代码已用 `Product.products(for:)` 动态加载，无需改代码）
7. 创建后等待 Apple 处理（通常几分钟到 1-2 小时），在 App 内付费墙点击 **"Restore Purchases"** 验证

### 🟢 App Store Connect 审核信息配置（提交审核前必需）

**影响功能**：不配置则 Apple 审核员无法理解 Screen Time API 用途与 AI 模式，有 Guideline 2.1(a) 拒审风险

**配置步骤**：
1. App Store Connect → SelahGate → **App Review Information**
2. 在 **Notes** 字段粘贴 `app_review_info.md`（项目根目录已生成）中的以下内容：
   - Screen Time API 说明（用户主动选择锁定哪些 App；Phone/Messages 不可锁）
   - AI 双轨说明（Apple 端侧 + BYO Key，默认关闭）
   - 订阅产品 ID 与价格
3. **Privacy Policy URL** 填：`https://asunnyboy861.github.io/SelahGate/privacy.html`
4. **Support URL** 填：`https://asunnyboy861.github.io/SelahGate/support.html`
5. **Terms of Use (EULA) URL** 填：`https://asunnyboy861.github.io/SelahGate/terms.html`（订阅 App 必填）
6. **Privacy Nutrition Label**：目标 **Data Not Collected**（BYO AI 开启时声明 User Content → Not Linked）
7. 建议上传一段演示视频（拦截页 → 祷告仪式 → Amen 金光解锁）到 Notes 附件

### 🟡 Family Controls (Distribution) 签名验证

**增强功能**：真机/TestFlight 分发必需
**已自动配置部分**：
- ✅ `.entitlements` 已包含 `com.apple.developer.family-controls` 与 Distribution 变体
- ✅ App Group `group.com.selahgate.app` 已配置（Team JP4TN5PTS3 自动签名，首次构建时自动注册）

**如遇签名失败，手动处理**：
1. 打开 [Apple Developer Identifiers](https://developer.apple.com/account/resources/identifiers/list)
2. 找到 `com.zzoutuo.SelahGate` → 编辑 → 勾选 **Family Controls (Distribution)** 与 **App Groups**
3. 重新 Build 验证（此能力 2023 起自动批准，无需人工申请）

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| Family Controls | entitlements 已配置（开发+Distribution 变体） | ✅ 已配置 |
| App Groups | `group.com.selahgate.app`，5 个 Target 共享 | ✅ 已配置 |
| 通知权限 | 本地通知（UserNotifications），无需 APNs 证书 | ✅ 已配置 |
| 相机权限 | NSCameraUsageDescription（拍纸质圣经解锁） | ✅ 已配置 |
| 出站网络 | 联系客服 + BYO AI 需要，HTTPS 默认放行 | ✅ 已配置 |
| 深链 URL Scheme | `selahgate://ritual`（ShieldAction 唤起主 App） | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers（feedback-board），URL 已写入 ContactSupportView | ✅ 已部署 |
| GitHub Pages | Landing/Support/Privacy/Terms 四页已上线 | ✅ 已部署 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 主 App | 13 屏 SwiftUI + SwiftData（App Group 容器），MVVM | ✅ 已完成 |
| 3 个系统扩展 | SelahGateMonitor / ShieldConfig / ShieldAction（DeviceActivity 四进程架构） | ✅ 已完成 |
| SelahGateWidget | 每日经文 Widget（Home/Lock Screen） | ✅ 已完成 |
| 经文库 | 1,398 节 KJV 公版经文 × 12 情绪标注（seven1m/bible_api 源） | ✅ 已完成 |
| 祷告库 | 96 篇人工撰写祷告 × 12 情绪（AI 降级兜底） | ✅ 已完成 |
| PurchaseManager | StoreKit 2，`Transaction.currentEntitlement(for:)` 响应式绑定 | ✅ 已完成 |
| AI 双轨 | Apple FoundationModels（iOS 26+ 端侧）+ BYO DeepSeek（Keychain）+ 本地兜底 | ✅ 已完成 |
| ContactSupportView | 7 主题块选 + 5 必填字段 + 后端对接（COMPLIANCE-CS 全项） | ✅ 已完成 |
| QA | 构建零警告、15/15 单测、iPhone 16 + iPad Pro 13 (M5) 真机启动验证 | ✅ 已完成 |
| AI 合规 | ios-custom-ai-config 13 项检查全过；无免费生成计数死代码 | ✅ 已完成 |

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub 仓库 | https://github.com/asunnyboy861/SelahGate （main 分支） | ✅ 已推送 |
| Landing Page | https://asunnyboy861.github.io/SelahGate/ （App Store ID 为占位符，上架后替换） | ✅ 已上线 |
| App Store 元数据 | keytext.md 已生成并通过 15 项验证（Keywords 100/100 满载） | ✅ 已完成 |
| 定价配置 | price.md 三档定价（Free/Pro/Lifetime） | ✅ 已完成 |

### 💡 使用提示（非开发者配置，App 内操作即可）

**AI 功能**：App 默认关闭 AI。iOS 26+ 且支持 Apple Intelligence 的设备上可在 Settings → AI → "Apple Intelligence (on-device)" 开启（免费、端侧、零配置）。其他设备用户可在 **Settings → AI → "My API key"** 输入自己的 DeepSeek 等 Key（Keychain 加密存储，任何档位无限使用）。这是用户操作，非开发者配置。

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据，内容已重组到上方 Section 一 和 Section 二。

### Analysis

基于操作指南关键词扫描（Screen Time API / FamilyControls / ManagedSettings / DeviceActivity / App Group / 通知 / 相机 / 拍照 / Widget / 订阅 / StoreKit / CloudKit P2）：
- Screen Time API（Family Controls + ManagedSettings + DeviceActivity）— 产品核心机制
- App Group — 四进程架构必需
- 通知（祷告提醒、"Your Selah is ready"）
- 相机（拍纸质圣经解锁，P1 已实现）
- WidgetKit（每日经文）
- StoreKit 2 / IAP（Pro 订阅 + 终身）
- CloudKit（P2 Prayer Circle — 延后，代码优雅降级）

### No Configuration Needed

- Push Notifications（APNs 证书）— 仅使用本地通知 + DeviceActivity 调度通知
- iCloud/CloudKit — P2 功能，延后，App 完全本地可用
- HealthKit / 定位 / Siri / Watch — 不在 MVP 范围

### Verification

- 构建验证：✅ BUILD SUCCEEDED（5 个 Target，Debug，iPhone 16 / iOS 26.4，零警告）
- Entitlements：✅ Family Controls + App Group 均正确
- 单元测试：✅ 15 通过 / 0 失败
