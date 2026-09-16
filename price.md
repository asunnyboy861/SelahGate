# Pricing Configuration

## Monetization Model: Subscription (IAP) + Lifetime Buyout

SelahGate is free to download with a genuinely generous permanent free tier (the category's #1 complaint is paywall-first competitors). Pro is offered as an auto-renewable subscription (monthly or yearly with 7-day free trial) or a one-time lifetime buyout. Brand promise: transparent pricing — no weekly subscription traps, prices shown before purchase, one-tap cancel guidance.

## Subscription Group
- **Group Name**: SelahGate Pro
- **Reference Name**: SelahGate Pro
- **Products in group**: `com.zzoutuo.SelahGate.pro.monthly`, `com.zzoutuo.SelahGate.pro.yearly` (auto-renewable only; Lifetime is a separate non-consumable)

## Subscription Tiers (Auto-Renewable)

### 1. Monthly Subscription
- **Reference Name**: SelahGate Pro Monthly
- **Product ID**: `com.zzoutuo.SelahGate.pro.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $4.99 USD per month
- **Display Name**: `SelahGate Pro Monthly` (21 chars, ≤35 ✅)
- **Description**: `Unlimited unlocks, Deep rituals, AI prayers` (44 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: SelahGate Pro
- **Restore Purchases**: ✅ Required

### 2. Yearly Subscription
- **Reference Name**: SelahGate Pro Annual
- **Product ID**: `com.zzoutuo.SelahGate.pro.yearly`
- **Type**: Auto-renewable subscription
- **Price**: $29.99 USD per year (50% savings vs monthly)
- **Display Name**: `SelahGate Pro Annual` (20 chars, ≤35 ✅)
- **Description**: `All Pro features, best value, 7-day free trial` (47 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: SelahGate Pro (same group as monthly)
- **Restore Purchases**: ✅ Required

## One-Time Purchases (Non-Consumable)

### 1. Pro Lifetime
- **Reference Name**: SelahGate Lifetime
- **Product ID**: `com.zzoutuo.SelahGate.pro.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $69.99 USD (one-time; launch-month promotional price $49.99 may be shown with strikethrough anchor $99.99)
- **Display Name**: `SelahGate Lifetime` (18 chars, ≤35 ✅)
- **Description**: `One purchase. All Pro features forever.` (40 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Note**: Sustainable because the AI primary channel has zero marginal cost (on-device Apple Foundation Models + user-supplied BYO key); no server costs. Choosing lifetime vs yearly: pay once and own it — cheaper than ~2.4 years of the annual plan.

## Free Tier (Default)

- **Price**: Free, forever
- **Features**:
  - Unlimited app guarding (shield blocking of selected apps/categories/web domains)
  - 3 prayer ritual unlocks per day (Light & Medium depths)
  - Full offline verse library (KJV & WEB, public domain)
  - Streak + GitHub-style heatmap + basic stats
  - Daily verse widget (Home/Lock Screen) + gentle reminders
  - 1 free Streak Freeze per month
  - SOS Grace emergency unlock (10 minutes, always available)
  - AI prayers: Apple on-device free quota (5/day on iOS 26+) + unlimited with user's own BYO API key
- **Conversion hooks**:
  - Free quota exhausted → soft wall offers three exits: start a deeper Pro ritual for a longer window, wait for tomorrow, or use SOS Grace — the phone is NEVER hard-locked
  - Transparent promise page shown BEFORE any paywall appears (trust-first onboarding step 5)
  - "Prices shown before you buy. No weekly traps. Cancel in Settings → Apple ID → Subscriptions — we'll even walk you there."

## Pro Features Unlocked (All Paid Tiers)

⚠️ Cross-referenced with `capabilities.md` — only features confirmed in us.md P0/P1 scope are listed. Prayer Circle is P2 and is NOT promised on the v1 paywall.

| Feature | Free | Pro (All Paid Tiers) |
|---------|:----:|:--------------------:|
| App guarding (shields) | ✅ Unlimited | ✅ Unlimited |
| Daily ritual unlocks | 3/day (Light & Medium) | ✅ Unlimited (all depths) |
| Deep prayer ritual (write ≥12 words) + 60-min focus window | ❌ | ✅ |
| Verse library (KJV & WEB) | ✅ Full | ✅ Full + multiple themed collections |
| AI-assisted prayers (on-device Apple FM) | 5/day | ✅ Amplified quota |
| AI prayers with BYO API key | ✅ Unlimited (own key) | ✅ Unlimited (own key) |
| Verse Vault collection | ✅ Collect on unlock | ✅ + full SRS spaced-repetition reviews |
| Monthly Spiritual Report (Wrapped-style share card) | ❌ | ✅ |
| Paper Bible photo unlock (BYO vision key) | ✅ If user has key | ✅ If user has key |
| Streak + heatmap + stats | ✅ | ✅ |
| Streak Freeze | 1/month | ✅ 1/month |
| SOS Grace | ✅ Always | ✅ Always |
| Widgets & reminders | ✅ | ✅ |
| Prayer Circle (family & friends) | ❌ Not in v1 | ❌ P2 roadmap — not shown on v1 paywall |

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid subscription; cancel anytime before it ends)
- **Available for**: `com.zzoutuo.SelahGate.pro.yearly` (full-feature trial)

## Policy Pages Required
- Support Page: ✅ (must include subscription management + cancellation instructions)
- Privacy Policy: ✅
- Terms of Use (EULA): ✅ (REQUIRED — subscription apps must have Terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms will be included in Terms of Use
- [x] Cancellation instructions will be included in Support Page ("Settings → Apple ID → Subscriptions → SelahGate")
- [x] Pricing clearly stated in PaywallView (free tier list shown FIRST, then Pro prices — no dark patterns)
- [x] Free trial terms included (7-day yearly trial)
- [x] Restore purchases functionality implemented (StoreKit 2 `Transaction.currentEntitlements` + `AppStore.sync()`)
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options or competitor prices
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
- [x] BYO Key model: AI generation is ALWAYS unlimited for users with their own key on any tier; no `freeGenerationsUsed` / `maxFreeGenerations` counting code; subscription value = app features, not AI usage
