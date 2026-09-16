# Capabilities Configuration

## Analysis
Based on operation guide analysis (keywords: Screen Time API / FamilyControls / ManagedSettings / DeviceActivity / App Group / 通知 / 相机 / 拍照 / Widget / 订阅 / StoreKit / CloudKit P2):

- Screen Time API (Family Controls + ManagedSettings + DeviceActivity) — core product mechanism
- App Group (group.com.selahgate.app) — required for 4-process architecture
- Notifications (prayer reminders, "Your Selah is ready")
- Camera (paper Bible photo unlock, P1)
- WidgetKit (daily verse widget)
- StoreKit 2 / In-App Purchase (Pro subscription + lifetime)
- CloudKit (P2 Prayer Circle only — deferred, graceful degradation without it)

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| App Bundle ID (`com.zzoutuo.SelahGate`) | ✅ Configured | pbxproj edit (was `com.zzoutuo.SelahGate.SelahGate`, fixed) |
| App Groups (`group.com.selahgate.app`) | ✅ Configured | SelahGate.entitlements |
| Family Controls | ✅ Configured | SelahGate.entitlements (`com.apple.developer.family-controls`) |
| Family Controls (Distribution) | ✅ Entitlement present | `com.apple.developer.family-controls.distribution` to be added at App Store distribution time by Xcode automatic signing |
| Camera usage description | ✅ Configured | INFOPLIST_KEY_NSCameraUsageDescription |
| FamilyControls usage description | ✅ Configured | INFOPLIST_KEY_NSFamilyControlsUsageDescription |
| Deep link URL scheme (`selahgate://`) | ✅ Configured | SelahGate/Info.plist CFBundleURLTypes |
| Development Team / Automatic Signing | ✅ Configured | Team JP4TN5PTS3, CODE_SIGN_STYLE=Automatic |
| App Icon (dawn-gold gate arch) | ✅ Generated | Agnes Image 2.1 Flash, icon_1024.png (RGB, no alpha) |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| App Group registration in Apple Developer portal | ⏳ Auto-registered at first build/sign | Automatic signing registers `group.com.selahgate.app` when signing with Team JP4TN5PTS3; verify at developer.apple.com → Identifiers if signing fails |
| StoreKit 2 products (`pro.monthly` / `pro.yearly` / `pro.lifetime`) | ⏳ Pending | Create in App Store Connect after app record exists; code uses StoreKit 2 `Product.products(for:)` which degrades gracefully (paywall shows products when available) |
| Family Controls (Distribution) signing | ⏳ Pending | Auto-approved capability since 2023; appears in Xcode Signing & Capabilities when building for distribution |

## No Configuration Needed
- Push Notifications (APNs certificates) — only local + DeviceActivity-scheduled notifications used (UserNotifications framework, no server push)
- iCloud/CloudKit — P2 feature; deferred. App fully functional with local-only storage.
- HealthKit / Location / Siri / Watch — not in MVP scope

## Extension Targets (created in PHASE 4+5 with code)
- SelahGateMonitor (DeviceActivityMonitor extension)
- SelahGateShieldConfig (Shield Configuration extension)
- SelahGateShieldAction (Shield Action extension)
- SelahGateWidget (WidgetKit extension)

## Verification
- Build succeeded after configuration: ✅ (build_sim, Debug, iPhone 16 / iOS 26.4)
- All entitlements correct: ✅ (Family Controls + App Group in SelahGate.entitlements)
- Simulator cleanup after test: ✅ (iPhone 16 UDID C77A1FB3-01CA-4997-A077-95CFB85AEDBB erased)
