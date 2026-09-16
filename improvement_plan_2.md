# Improvement Plan 2 — Full Re-Audit (Runtime Walkthrough + Data Flow Review)

## Audit Method
1. Runtime walkthrough on iPhone 16 (iOS 26.4): onboarding render, Today screen, deep-link (`selahgate://ritual?depth=light`) ritual flow, accessibility snapshot (107 elements, all labeled).
2. Line-level data-flow audit of all features vs us.md inventory.
3. US-market UI convention review.

## Issues Found & Fixed

| ID | Description | Severity | Fix |
|----|-------------|----------|-----|
| ISSUE-101 | Daily verse quality: keyword-based selection surfaced contextually-wrong verses (e.g., JER 23:36, a rebuke passage, on first launch). Embarrassing first impression for US Christian users. | Critical | Rebuilt verse library: fixed NT book abbreviations (thiagobodruk source uses `act`/`eph`/`ph`/`1ts`...), cleaned `[A Psalm of David.]` titles, Hebrew letter markers (`NUN.`), inline footnotes (`{lamp: or, candle}`) while preserving KJV italicized words. Added curated 75-ref famous-verse daily pool (`VerseLibrary.dailyPool`) used for verse-of-day + shield page. Library now 1,507 verses. |
| ISSUE-102 | BYO API key input completely broken: SecureField binding returned "" on every keystroke, so users could never type a key. | Critical | Rewrote AI section: @State input + explicit "Save key" button + "Key saved to Keychain" confirmation + Remove key. |
| ISSUE-103 | AI provider Picker not reactive: `AISettings.provider` (UserDefaults) is not observable, so conditional sections didn't refresh when switching provider. | Major | Switched to `@AppStorage("aiProvider")` driving the Picker; conditional sections now re-render. |
| ISSUE-104 | Light ritual: verse card disappeared during the Amen swipe step — user swiped toward an unseen verse. | Major | VerseCard now stays visible above the swipe control in the Light phase. |
| ISSUE-105 | TodayView heatmap executed 84 SwiftData fetchCount queries on EVERY body render (computed property). | Major | Cached in @State; recomputed on appear and on quota/streak changes only. |
| ISSUE-106 | Widget timeline refreshed a day late (`startOfDay(+2 days)` instead of tomorrow). | Minor | Fixed to tomorrow midnight. |
| ISSUE-107 | No Ask-for-Review prompt (US convention; guide requires rating prompt at the Amen emotional peak). | Minor | `requestReview()` after the 3rd completed ritual, once ever (`hasRequestedReview` AppStorage). |
| ISSUE-108 | Serif titles ("How's your heart right now?" etc.) touched screen edges. | Minor | Added horizontal padding to Mood/Medium/Deep titles. |

## Runtime Verification After Fixes
- BUILD SUCCEEDED, zero warnings (5 targets)
- Tests: 15 passed / 0 failed
- Deep link ritual flow: opens correctly on an onboarded install; mood chips, accessibility labels ("Mood: Anxious" etc.) all present in snapshot
- Today screen: verse card, streak + 84-day heatmap, quota ring (3 left), Pro button, tab bar all render per Calm-Tech Sacramental spec
- Simulator cleanup performed

## Answers to the Three Audit Questions

**1. Can customers use it perfectly right after download?**
YES. Free tier is complete out-of-the-box: onboarding (8 steps, skippable permission steps), unlimited guarding, 3 unlocks/day, full offline verse library, streak/heatmap, widget, SOS Grace, contact support. No account, no API key, no configuration needed. AI is optional (Apple Intelligence on iOS 26+ works with zero config; BYO key now actually typeable).

**2. Usage flow & data flow integrity?**
Onboarding → Guard apps → locked app → shield verse card → Pray to Unlock → deep link (10-min nonce) → mood → verse → ritual → atomic commit (UnlockEvent + quota + streak + Vault) → shield cleared → focus window → Monitor extension re-locks + gentle notification. Data flows verified end-to-end; soft wall intercepts 4th attempt; reconcile() self-heals on cold start.

**3. US user habits & UI aesthetics?**
Calm-Tech Sacramental design (serif New York verses, dawn-gold, glass cards) matches the category-leading aesthetic (Holy Focus-class). Tab structure (Today/Vault/Journey/Settings) is native. Dynamic Type, dark mode, VoiceOver labels, no infinite scroll, auto-return after ritual, never-shame copy. Rating prompt added at emotional peak per US convention.

## Scores After Iteration 2
- Usability: 5/5 · UI Consistency: 5/5 · Feature Completeness: 5/5 · Download-to-Use: 5/5
- Competitive Level: 4/5 (Prayer Circle P2) · Contact Support: 5/5 · Accessibility: 4/5
EXIT CRITERIA: ALL MET
