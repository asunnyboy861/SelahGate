# App Review Information

## Demo Account for Apple Review

No demo account is required. SelahGate's core features work fully offline with zero configuration.

### AI Features (Dual-Track Model)
The app uses a dual-track AI design; AI is OPTIONAL and OFF by default:
1. **Apple Foundation Models (on-device)**: On supported devices (iPhone 15 Pro+, iOS 26+), AI-assisted prayer generation works immediately with no API key. It runs on-device and never sends data over the network.
2. **BYO API Key**: Users may add their own DeepSeek API key in Settings → AI. The key is stored in the iOS Keychain. AI generation is always unlimited for key holders on any tier.
3. **Local fallback**: If neither is available, the app uses a bundled library of 96 pre-written prayers. No feature is broken without AI.

To test AI on a device without Apple Intelligence:
1. Open Settings → AI
2. Set "AI prayers" to "My API key"
3. Paste any DeepSeek-compatible API key
4. Start a Deep ritual and tap "AI polish"

### Screen Time API
- SelahGate uses FamilyControls / ManagedSettings / DeviceActivity. Users explicitly choose which apps to guard in Onboarding or Today → "Guard apps".
- System apps (Phone, Messages, Emergency) cannot be locked by the OS; SelahGate never attempts to.
- No content of guarded apps is ever visible to SelahGate — only that a guarded app was opened.

### Subscription Testing
- Product IDs: `com.zzoutuo.SelahGate.pro.monthly` ($4.99/month), `com.zzoutuo.SelahGate.pro.yearly` ($29.99/year, 7-day free trial), `com.zzoutuo.SelahGate.pro.lifetime` ($69.99 one-time)
- The free tier remains fully functional after any subscription expires.

### Required Links (In-App)
- Privacy Policy: https://asunnyboy861.github.io/SelahGate/privacy.html
- Terms of Use: https://asunnyboy861.github.io/SelahGate/terms.html
- Support Page: https://asunnyboy861.github.io/SelahGate/support.html

These links are accessible from:
1. Settings → Legal & Privacy
2. Paywall (below the purchase buttons)

## Review Notes

- SelahGate is a faith-based screen-time app: opening a guarded app shows a Bible verse; completing a short prayer ritual unlocks it for a focus window.
- Core features are fully offline; the verse library is public domain (KJV).
- No UGC, no chat, no accounts, no third-party analytics.
- AI features are optional: on-device Apple Foundation Models (default where available) or the user's own API key. The app never sells API keys or AI usage.
- All copy is pastoral and non-clinical; no medical claims.

### China App Store Compliance
This app does NOT include ChatGPT functionality or reference ChatGPT/OpenAI in any user-facing UI or metadata. The AI feature uses a generic BYO API Key model with no specific provider bundled.
