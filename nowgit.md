# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | SelahGate |
| **Git URL** | git@github.com:asunnyboy861/SelahGate.git |
| **Repo URL** | https://github.com/asunnyboy861/SelahGate |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ⏳ Pending (enabled in PHASE 7 from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/SelahGate/ | ✅ Active |
| Support | https://asunnyboy861.github.io/SelahGate/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/SelahGate/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/SelahGate/terms.html | ✅ Active |

## Repository Structure

```
SelahGate/
├── SelahGate/                        # iOS App Source Code
│   ├── SelahGate.xcodeproj/          # Xcode Project (5 targets)
│   ├── SelahGate/                    # Main App (SwiftUI + SwiftData)
│   │   ├── Views/                    # Onboarding, Today, Ritual, Vault, Stats, Paywall, Settings, Support
│   │   ├── Models/                   # UnlockEvent, DailyState, VerseVaultEntry, PrayerEntry
│   │   ├── Services/                 # GuardModel, GuardScheduler, RitualStore, PurchaseManager, PrayerEngine
│   │   ├── verses_kjv.json           # 1,398 public-domain KJV verses, mood-tagged
│   │   └── prayers_bundle.json       # 96 pre-written prayers × 12 moods
│   ├── SharedKit/                    # Shared models, verse library, theme, Keychain (all targets)
│   ├── SelahGateMonitor/             # DeviceActivityMonitor extension
│   ├── SelahGateShieldConfig/        # Shield Configuration extension (offline verse card)
│   ├── SelahGateShieldAction/        # Shield Action extension (deep link)
│   └── SelahGateWidget/              # WidgetKit daily verse
├── docs/                             # Policy Pages (GitHub Pages source, PHASE 7)
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── capabilities.md
├── icon.md
├── price.md
├── nowgit.md
├── app_review_info.md
├── improvement_plan_1.md
├── keytext.md              # ⚠️ EXCLUDED from repo (.gitignore — confidential ASO strategy)
└── COMPETITOR_REPORT.md    # ⚠️ EXCLUDED from repo (.gitignore — confidential competitor analysis)
```

## Build Verification

| Target | Status |
|--------|--------|
| SelahGate (main app) | ✅ BUILD SUCCEEDED |
| SelahGateMonitor | ✅ BUILD SUCCEEDED |
| SelahGateShieldConfig | ✅ BUILD SUCCEEDED |
| SelahGateShieldAction | ✅ BUILD SUCCEEDED |
| SelahGateWidget | ✅ BUILD SUCCEEDED |
| Unit tests | ✅ 15 passed / 0 failed |
| iPhone 16 (iOS 26.4) run test | ✅ Launch verified |
| iPad Pro 13-inch (M5) run test | ✅ Launch verified |
