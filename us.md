# SelahGate - iOS Development Guide

> Translated & adapted from: `TR-20260915-信仰锁机操作指南.MD` (2026-09-15). Competitor data in the source guide was freshly verified on 2026-09-15 (Tavily / App Store / Google Play / Reddit / Starter Story) and is used directly here.

## Executive Summary

**SelahGate** — the faith app blocker with a real free tier, three unlock depths, a verse memory vault, and free on-device AI. Tagline: **"Pray Before You Scroll."**

- **Product essence**: Not a screen-time tool — an *attention redemption ritual*. Every distracting unlock becomes a 30-second prayer ritual. Users buy meaning, not blocking.
- **Target audience**: US Christians (62% of US adults identify as Christian) who reach for their phone before their Bible; secondary: other faiths via content packs (P2).
- **Category**: Lifestyle (secondary: Productivity). Age rating 4+.
- **Key differentiators (7 crushing points vs. competitors)**:
  1. **Real free tier**: unlimited guarding + 3 free ritual unlocks/day + full offline verse library — forever free.
  2. **Three unlock depths** (Light / Medium / Deep — user-selectable friction).
  3. **Verse Vault**: unlock-triggered verse collection + SM-2 spaced repetition + heatmap.
  4. **AI dual-track at zero cost**: Apple Foundation Models (on-device, free) + BYO DeepSeek key (Keychain-stored) + 500-prayer local fallback library.
  5. **Transparent pricing**: no weekly traps, prices shown before purchase, one-tap cancel guidance.
  6. **Privacy-minimal**: core features make ZERO network requests (verses fully offline); AI only egresses when user enables it.
  7. **Never shame**: streak freeze, SOS Grace emergency unlock, "Day 0 is still holy."

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Prayer Lock (research subject) | Category #1, 4.9 stars, mood-matched prayers | Subscription required ("no features without one"), no journaling, no AI, no family | Real free tier, Verse Vault, AI, transparent pricing |
| FaithLock | Orthodox positioning, 200+ verses | $9.99/WEEK ($520/yr annualized!), paywall-first, forced quiz | 3 free unlocks/day, adjustable friction, $29.99/yr (60% of their annual) |
| Holy Focus | 300+ prayer cards, "most beautiful in category" | Passive reading ("Nothing stops you from half-reading"), ~$6.49/mo | Active rituals with depth tiers, cheaper annual |
| VerseGate | "No network requests at all" trust anchor | £34.99/yr, hardcore 3-question quiz deters casual users | Offline too, plus adjustable friction + free tier |
| Psalmo | Core free, daily verse gate | Shallow features, once-a-day gate only | Deep rituals, unlimited guarding, verse memory |
| Sanctum / Alma | AI chat, mood check-ins | Shallow AI behind paywall, repetitive flow complaints | Free on-device AI + BYO, never-shame design |

**Market gap**: "Generous free tier + honest mid-price" product does not exist — incumbents are either predatory (FaithLock) or shallow (Psalmo).

## Apple Design Guidelines Compliance

- **Human Interface Guidelines**: Native SwiftUI, system materials (glass morphism light cards), Dynamic Type support to XL, full dark mode from day 1, accessibility labels on all components, VoiceOver walkthrough of all 13 screens.
- **Screen Time API guidelines**: Family Controls (Distribution) entitlement (auto-approved since 2023); Phone/Messages/Emergency never lockable (system constraint, documented in FAQ); Review Notes with demo video.
- **Subscription compliance (3.1.2)**: Paywall includes functional Privacy Policy + Terms (EULA) links, price disclosure, auto-renewal text, restore purchases button.
- **Content safety (4.7 / religious)**: Zero medical/therapy language ("gentle focus" not "treat anxiety"); verses NEVER AI-generated (hallucinated scripture = religious product incident); KJV/WEB public domain attribution in About.
- **Privacy label target**: **Data Not Collected**; BYO AI declares User Content → Not Linked.

## Technical Architecture

- **Language**: Swift 6 / SwiftUI / iOS 17.0+ (AI features degrade gracefully below iOS 26)
- **Processes (4 targets, zero backend)**:
  1. **SelahGate** (main app): SwiftUI + SwiftData — ritual, config, stats, paywall
  2. **SelahGateMonitor** (DeviceActivityMonitor extension): threshold/schedule events → App Group
  3. **SelahGateShieldConfig** (ShieldConfiguration extension): shield visuals (offline verse card)
  4. **SelahGateShieldAction** (ShieldAction extension): button actions → deep link to main app
- **SharedKit**: shared framework (models / App Group tools / verse library / theme) — NO duplicated models across extensions
- **Data**: SwiftData (container pointed at App Group URL) + App Group UserDefaults; verses from bundled JSON (KJV/WEB public domain)
- **Frameworks**: FamilyControls, ManagedSettings, ManagedSettingsUI, DeviceActivity, StoreKit 2, WidgetKit, CloudKit (P2 only), FoundationModels (iOS 26+, optional), UserNotifications
- **Dependencies**: ZERO third-party mandatory dependencies

### Module Structure

```
SelahGate/
├── SelahGate (App, SwiftUI, iOS 17+)
│   ├── Views/ (Onboarding, Today, Ritual, VerseVault, Stats, Paywall, Settings)
│   ├── Models/ (SwiftData: UnlockEvent, VerseVaultEntry, PrayerEntry, DailyState, Settings)
│   ├── Services/ (GuardModel, GuardScheduler, RitualStore, PrayerEngine, Quota, Streak)
│   └── SharedKit (framework)
├── SelahGateMonitor (DeviceActivityMonitor extension)
├── SelahGateShieldConfig (ShieldConfiguration extension)
├── SelahGateShieldAction (ShieldAction extension)
├── SelahGateWidget (WidgetKit: daily verse, Home/Lock Screen)
└── Resources/
    ├── verses_kjv.json (~1200 curated tagged verses + full library)
    ├── prayers_bundle.json (500 pre-generated prayers × 12 moods)
    └── Assets.xcassets
```

### Entitlements (critical — one mistake breaks everything)

```xml
<key>com.apple.developer.family-controls</key><true/>
<key>com.apple.developer.family-controls.distribution</key><true/>
<key>com.apple.security.application-groups</key>
<array><string>group.com.selahgate.app</string></array>
```

Info.plist: `NSFamilyControlsUsageDescription`, `NSCameraUsageDescription` (paper Bible photo unlock).

## ⚠️ Feature Inventory (MANDATORY)

### Primary Features (MVP = P0 required for release)

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | FamilyControls authorization + app selection | Onboarding → "Grant Access" → system prompt → FamilyActivityPicker (pre-checked common distractors) → "Guard these" | Screen Time permission; selected apps/categories/web domains | `AuthorizationCenter.requestAuthorization(.individual)`; archive FamilyActivitySelection tokens | Shield applied to selected apps; picker shows current selection | App Group: archived selection (TokenCodable) | Selecting Instagram → opening Instagram shows shield within seconds |
| 2 | ManagedSettings shield + custom verse-card shield page | User taps locked app → system shield appears | ApplicationToken set | ShieldConfig extension reads verse library (deterministic "verse of the day") | Dawn-gold gradient, gate arch icon, serif verse card, gold "Pray to Unlock", gray "Not now" | None (stateless render) | Shield renders <300ms; verse matches main app's verse-of-day |
| 3 | Three-depth unlock ritual | Shield "Pray to Unlock" → deep link `selahgate://ritual` → mood chips (skippable) → verse card → depth step → "Amen" | Mood tag (optional); ritual completion | Light: read 3s + swipe Amen / Medium: fill-in-blank 4-choice / Deep: write prayer ≥12 words; gold burst + success haptic | Focus window opened (15/30/60 min); UnlockEvent recorded | SwiftData: UnlockEvent, DailyState | Each depth path completes and unlocks; wrong Medium answer highlights re-read, never dead-ends |
| 4 | Real free tier + quota | Any unlock attempt | freeRitualsUsed counter | Lazy daily reset on read; `pro \|\| used < 3`; over quota → soft wall page (3 exits: Pro / tomorrow / SOS Grace) — NEVER hard-lock the phone | Quota ring on Today (3-segment); soft wall when exhausted | SwiftData DailyState.freeRitualsUsed | 4th unlock attempt same day shows soft wall, not a dead phone |
| 5 | Streak + GitHub heatmap + stats | Today / Stats tab | UnlockEvents by day | Streak computation (freeze-aware: 1 free freeze/month); aggregate focus minutes, "Scroll resisted" count | 52×7 heatmap grid, flame streak, weekly prayer minutes | SwiftData DailyState (currentStreak, longestStreak, focusMinutes, freezeUsed) | Break day shows "Day 0 is still holy. Begin again." — no zero-shaming |
| 6 | StoreKit 2 paywall (transparent) | Soft wall / Settings / paywall entry | Product selection | Load `pro.monthly` ($4.99), `pro.yearly` ($29.99, 7-day trial), `pro.lifetime` ($69.99); Transaction.updates listener; restore purchases | Free-tier list FIRST, then Pro list, prices, cancel-guidance footnote, Privacy + EULA links | App Group: pro flag (shared with extensions) | Purchase flips pro flag; free tier remains fully functional after trial ends |
| 7 | Daily verse Widget + prayer reminder notifications | Widget gallery add; notification permission (onboarding step 6) | Verse-of-day index (deterministic by day) | WidgetKit timeline provider reads App Group verse index | Home/Lock Screen widget with serif verse; "Your Selah is ready" notification when focus window ends | App Group shared verse index | Widget shows same verse as shield page for the day |
| 8 | Mood tags (12) × verse theme routing | Ritual mood step (skippable) | Mood chip tap | Local rule-based routing: mood → tagged verse pool → weighted random excluding recently seen | Mood-matched verse | Verse JSON mood arrays | Each of 12 moods returns a thematically correct verse |
| 9 | SOS Grace + emergency exemption | Soft wall / Settings → "SOS Grace" | Tap | 10-minute shield exemption, recorded as usedSOS event, blessed not shamed | "Grace covers today." toast; logged with usedSOS=true | UnlockEvent.usedSOS | Phone never hard-locked; SOS always available |

### P1 Features (within 2 weeks post-release — include in codebase)

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 10 | Apple Foundation Models on-device AI prayers (Pro amplifies; free users get 5/day) | Settings → AI on (default off); Ritual Deep → AI polish | moodTag + last-7-day mood summary + local verse ref | `FoundationModels` LanguageModelSession streaming; guardrails: 60–90 words, grounded in given verse, never invent scripture, no medical/financial advice | Streaming prayer text labeled "AI-assisted" | PrayerEntry(origin=ai_local) | Works with zero config on iOS 26+ devices; silently falls back below |
| 11 | BYO DeepSeek key (text + vision) | Settings → "Bring your own key" → paste key → Keychain store | API key; optional photo of paper Bible page | DeepSeek chat/completions SSE streaming; photo path: vision → verse match (3-gram fuzzy) → unlock + Verse Vault entry; failure falls back to normal ritual, no punishment | Unlimited AI prayers; paper-Bible unlock | Keychain (NEVER UserDefaults); PrayerEntry(origin=ai_cloud) | Key never appears in logs; camera flow matches a KJV verse |
| 12 | Verse Vault SRS + share card | Auto-collection on each unlock; nightly 8pm review prompt | SM-2 quality self-rating 0–5 | SM-2: easiness/interval/reps/due-date; mastery flag; share-card image export | Verse collection grid (book-progress badges), due-review card | SwiftData VerseVaultEntry | Wrong recall reschedules to tomorrow (never shaming); share card renders |
| 13 | Monthly Spiritual Report (Wrapped-style) | Stats → "This month in prayer" | Aggregated UnlockEvents | Compute totals: prayer minutes, top mood, verse of the month; render shareable image with logo+tagline | Image export → system share sheet | None (derived) | Share card exports and includes brand tagline |

### P2 Features (viral engine, month 2 — stub/flag only, not blocking release)

| # | Feature | Description |
|---|---------|-------------|
| 14 | Prayer Circle | Invite link (2–8 people), shared streak, anonymous prayer wall (CloudKit public DB, anonymous, no custom server) |
| 15 | Multi-faith content packs | IAP extensions: Catholic / Jewish / Muslim / Buddhist (public-domain texts) |
| 16 | iPad / macOS Catalyst adaptation | Layout adaptation of 13 screens |

### Sub-Features & Detail Interactions

| # | Parent | Sub-Feature | Detail | Interaction |
|---|--------|-------------|--------|-------------|
| 3.1 | Ritual | Mood skip | "Skip" link top-right; mood optional | Tap |
| 3.2 | Ritual | Verse card 3s guard | Light: primary button enabled after 3s read delay | Timer |
| 3.3 | Ritual | Medium wrong answer | Wrong pick → highlight correct line, re-read; never trap | Tap |
| 3.4 | Ritual | Deep word count ring | ≥12 words progress ring enables Amen | Text input |
| 3.5 | Ritual | Amen burst | Radial gold light scale 0.6→1.6 fade + success haptic; "Go with peace 🕊" | Auto 1.2s → dismiss |
| 5.1 | Stats | Streak Freeze | 1 free/month; break day shows "Begin again" not reset | Automatic |
| 6.1 | Paywall | Cancel guidance | "Settings → Apple ID → Subscriptions → SelahGate. We'll even walk you there." + deep link | Tap opens system subscriptions |
| 9.1 | Settings | Pause guarding | 2-step + one verse interstitial "One breath before you go?" | Confirm flow |
| 10.1 | AI | Degradation chain | Apple FM (available?) → BYO key (present?) → 500-prayer local library (always) | Automatic silent fallback |
| 13.1 | Onboarding | 8-step 90s flow | Resonance pick → permission card → picker → depth choice → free-tier transparency page → notifications → first ritual (golden-finger moment: completes one Light unlock) → "Day 1 begins. 🕊" | Swipe-back always available |
| — | All | reconcile() self-heal | Every cold start: recompute shield expected state from DailyState + schedule; fix drift (prevents "stuck on shield" competitor bug) | Automatic |
| — | All | Deep-link nonce | pendingRitual JSON with nonce, 10-minute expiry, replay protection; cold start waits ≤800ms skeleton | Automatic |

### Cross-Feature Dependencies

| Dependency | Source | Target | Data Passed | Trigger |
|------------|--------|--------|-------------|---------|
| Ritual completion → shield lift | Ritual | GuardModel | clearAllShields() + new focus-window threshold | Amen |
| Ritual completion → Verse Vault | Ritual | Verse Vault | verseRef of unlocked verse | Every unlock |
| Ritual completion → quota/streak | Ritual | DailyState | atomic transaction: UnlockEvent + used+1 + streak recompute | Every unlock |
| ShieldAction → main app | Shield extension | Ritual | pendingRitual JSON via App Group + deep link nonce | "Pray to Unlock" |
| Focus window end → re-shield | Monitor extension | ManagedSettingsStore | re-apply shield from archived selection + notification | eventDidReachThreshold |
| Pro purchase → quota bypass | Paywall | Quota/extension | App Group pro flag | Transaction verified |
| Verse-of-day index | Verse library | Shield + Widget + Today | dayIndex % curatedCount | Daily |

## ⚠️ Data Flow Diagram (Every Feature's Lifecycle)

### Feature: Unlock Ritual (core, runs N times daily)

```
User Input
└── Tap "Pray to Unlock" on shield
     │
ShieldAction extension
└── Write pendingRitual JSON {source, depth, ts, nonce} to App Group UserDefaults
└── openURL("selahgate://ritual?n=nonce") via responder chain + completionHandler(.close)
     │
Main App (RitualScreen)
└── onOpenURL → validate nonce freshness (>10 min → discard, anti-replay)
└── Quota check: pro || freeRitualsUsed < 3 (else soft wall)
└── Mood chips (skippable) → VerseCard (local library, deterministic) → depth step → Amen
     │
Persistence (atomic SwiftData transaction — crash can never split these)
└── UnlockEvent(id, ts, sourceApp hash, depth, moodTag, verseRef, ritualSeconds, usedSOS)
└── DailyState.freeRitualsUsed += 1, streak recompute
└── VerseVaultEntry created if new verse
     │
Display Output
└── clearAllShields() → "Go with peace 🕊" → auto-dismiss → user back in original app
└── GuardScheduler.schedule(focusMinutes: 15/30/60) → DeviceActivityEvent threshold
```

### Feature: Re-lock & Daily Reset

```
DeviceActivitySchedule 00:00–23:59 daily
└── intervalDidStart → apply daily shield
└── User unlocks → focus window (15/30/60 min)
└── eventDidReachThreshold (Monitor ext) → re-apply shield from App Group selection
└── Gentle notification "Your Selah is ready"
└── DailyState lazy reset on read (date change → freeRitualsUsed=0, streak evaluate, freeze=false)
```

### Feature: AI Prayer Degradation Chain

```
Prayer request {moodTag, 7-day trend}
└── Apple FM available? (iOS 26+ && Apple Intelligence on) → on-device stream, zero cost, no egress
└── else BYO DeepSeek key in Keychain? → chat/completions SSE (text) / vision (photo Bible)
└── else → local 500-prayer bundle, moodTag + dedup rotation (ALWAYS succeeds)
└── Output labeled "AI-assisted"; verse reference ALWAYS from local library (never AI-invented)
```

**Data-integrity rules (anti-fake-data principles)**: (1) nonce expiry 10 min; (2) single atomic write for unlock+quota; (3) reconcile() self-heal every cold start; (4) stats can never be faked — no "I prayed" free buttons; verse selection is deterministic from local library.

## Implementation Flow

1. Project skeleton: 4 targets + SharedKit + App Group + entitlements verified on device
2. AuthorizationCenter wrapper + FamilyActivityPicker screen + selection persistence (TokenCodable archive)
3. applyShield / clearShield via single GuardModel entry point
4. ShieldConfig extension (static verse card) + ShieldAction extension + deep link
5. Ritual Light full flow → SwiftData container (App Group URL) → UnlockEvent/DailyState atomic transactions → Quota lazy reset
6. Medium fill-in + Deep handwriting steps
7. DeviceActivity schedule + threshold re-lock + Monitor extension + reconcile() self-heal
8. Streak + Freeze + heatmap component + stats
9. WidgetKit daily verse + notifications
10. Onboarding 8 steps + transparent paywall UI + StoreKit 2 + restore purchases
11. SOS Grace + soft wall page
12. Verses JSON pipeline (curated ~1200 tagged KJV/WEB from `seven1m/bible_api` public domain) + 500-prayer bundle
13. PrayerEngine degradation chain + AppleFMProvider + DeepSeekProvider (Keychain) + photo-Bible vision unlock
14. Verse Vault SRS + monthly Spiritual Report share card
15. Accessibility pass, dark mode full adaptation, unit tests (Quota/SRS/VerseDedup/nonce at 100%)

## UI/UX Design Specifications

**Design language: "Calm-Tech Sacramental"** — editorial serif large type + earth-tone warmth + glass-morphism light cards + large corner radii + generous whitespace. "Like a morning devotional card, not a parental-control dashboard."

- **Colors**: bg/porcelain `#F7F3EC` / dark `#12100E`; card white 60% glass; ink `#1C1917`/`#F7F3EC`; accent gold `#B4884B`/`#D9A85E`; sage `#7D8F69`; dawn gradient `#FDF0DD→#EAC98F` (dark `#2A2118→#4A3A22`)
- **Typography**: Verses/titles = **New York** (system serif) 34–40pt, line-height 1.35; body SF Pro 17pt; streak numbers SF Pro Rounded
- **Key components**: MoodChip (gold bg on select, 1.06 scale); VerseCard (glass + serif + gold bookmark line); AmenButton (full-width 56pt gold, press 0.97, radial gold burst + heavy→success haptic); StreakGrid (52×7, today breathing outline); QuotaRing (3 segments, used = extinguished)
- **Animations**: ritual transitions spring(0.5, 0.85); verse lines fade in opacity+blur 0.4s staggered; shield page has NO animation (reverence = speed, extension budget tight)
- **13 screens**: Today, App Picker, Shield page, Ritual-Mood, Ritual-Verse, Ritual-Medium, Ritual-Deep, Amen, Verse Vault, Stats, Prayer Circle (P2), Paywall, Settings
- **Hard rules**: no infinite scroll anywhere (everything has an end); no tutorial popups (3-second rule); auto-return after ritual (no retention traps); dark mode day 1; v1 English only

## App Icon

Dawn-gold gradient background (#FDF0DD→#EAC98F), centered **gate arch silhouette** with a vertical morning-light slit in the door seam; no text.

## Code Generation Rules

- All shared code in SharedKit; never duplicate models across extensions
- Never touch ManagedSettingsStore off main thread; all shield changes through GuardModel
- NO network requests inside extensions (memory/time limits + review risk); shield page always offline resources
- BYO Key in Keychain ONLY (never UserDefaults/Plist/logs); redact debug logs
- SwiftData container URL = App Group container URL; serialize writes via actor
- All user-facing copy in English, tone "pastoral, never preachy"; FORBIDDEN words: cure, treat, anxiety treatment, addiction therapy
- Accessibility labels every screen; Dynamic Type to XL; dark/light dual theme
- Unit tests: Quota / SRS / VerseDedup / nonce-expiry at 100%
- Version read dynamically via `Bundle.main.infoDictionary` — never hardcode

## ⚠️ App Store Compliance — AI Features

This app uses a dual-track AI design: Apple Foundation Models (on-device, default where available) + BYO DeepSeek key. AI is OFF by default; core features need no AI.

- **iOS 26+**: Apple Intelligence on-device generation available (free users: 5/day; Pro: amplified)
- **iOS < 26 / unsupported devices**: silent fallback to local 500-prayer library — no missing-feature feeling, no dead buttons
- BYO key stored in Keychain; egress limited to {mood, verse ref, 7-day mood summary} — never device/behavior data
- `canGenerate` logic: `isPremium || hasAPIKey || appleIntelligenceAvailable` — NO free-generation counting dead code
- Create `app_review_info.md` with reviewer guidance
- NEVER: `freeGenerationsUsed` / `maxFreeGenerations` / dead AI buttons

## ⚠️ App Store Compliance — Subscriptions

Paywall MUST contain: functional Privacy Policy link, Terms of Use (EULA) link, product title/length/price, auto-renewal disclosure, Restore Purchases button. Subscription value framed as "Unlock Premium Features" (features-first, not AI-usage-first). BYO AI is always unlimited for key-holders on any tier.

## Build & Deployment Checklist

- [ ] Family Controls (Distribution) entitlement packaged & verified on real device via TestFlight
- [ ] Info.plist: `NSFamilyControlsUsageDescription`, `NSCameraUsageDescription`
- [ ] Review Notes: demo video + "users choose what to lock; Phone/Messages unlockable; no UGC; core offline"
- [ ] Privacy label: Data Not Collected (+ User Content/Not Linked if AI enabled)
- [ ] Age 4+; Lifestyle; zero medical language
- [ ] EULA + Privacy links on paywall + Restore Purchases
- [ ] KJV/WEB public-domain statement in About
