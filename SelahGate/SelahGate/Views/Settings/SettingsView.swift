import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    @State private var pauseVerseVisible = false
    @AppStorage("eveningReminder") private var reminderEnabled = false
    @AppStorage("defaultDepth") private var defaultDepth = RitualDepth.light.rawValue
    @AppStorage("bibleTranslation") private var bibleTranslation = "KJV"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private var pauseVerse: Verse { VerseLibrary.randomToday() }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                guardingSection
                ritualSection
                aiSection
                proSection
                legalSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.porcelain)
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .confirmationDialog("One breath before you go?", isPresented: $pauseVerseVisible, titleVisibility: .visible) {
                Button("Pause guarding") {
                    GuardModel.shared.pauseGuarding()
                }
                Button("Keep guarding", role: .cancel) {}
            } message: {
                Text("\"\(pauseVerse.text)\" — \(pauseVerse.ref)")
            }
        }
    }

    private var guardingSection: some View {
        Section("Guarding") {
            NavigationLink("Choose apps to guard") {
                AppPickerScreen()
            }
            Button("Pause guarding") {
                pauseVerseVisible = true
            }
            .foregroundStyle(.primary)
            Toggle("Evening verse reminder (8 PM)", isOn: $reminderEnabled)
                .onChange(of: reminderEnabled) {
                    if reminderEnabled {
                        Task {
                            if await NotificationHelper.requestAuthorization() {
                                NotificationHelper.scheduleEveningReminder()
                            } else {
                                reminderEnabled = false
                            }
                        }
                    } else {
                        NotificationHelper.cancelEveningReminder()
                    }
                }
        }
    }

    private var ritualSection: some View {
        Section("Ritual") {
            Picker("Default depth", selection: Binding(
                get: { RitualDepth(rawValue: defaultDepth) ?? .light },
                set: { defaultDepth = $0.rawValue }
            )) {
                ForEach(RitualDepth.allCases, id: \.self) { d in
                    Text("\(d.title) · \(d.windowMinutes) min").tag(d)
                }
            }
            Picker("Bible translation", selection: $bibleTranslation) {
                Text("KJV").tag("KJV")
                Text("WEB").tag("WEB")
            }
        }
    }

    private var aiSection: some View {
        Section {
            Picker("AI prayers", selection: Binding(
                get: { AISettings.provider },
                set: { AISettings.provider = $0 }
            )) {
                Text(AIProviderSetting.off.title).tag(AIProviderSetting.off)
                Text(AIProviderSetting.apple.title).tag(AIProviderSetting.apple)
                Text(AIProviderSetting.byo.title).tag(AIProviderSetting.byo)
            }
            if AISettings.provider == .apple {
                Text(PrayerEngine.shared.appleIntelligenceAvailable
                     ? "Apple Intelligence is available on this device. Prayers generate on-device, free and private."
                     : "Apple Intelligence requires a supported iPhone (iOS 26+). The app falls back to the built-in prayer library.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if AISettings.provider == .byo {
                SecureField("API key", text: Binding(
                    get: { "" },
                    set: { AISettings.saveKey($0) }
                ))
                Text("Bring your own key — unlimited AI prayers, billed by your own provider. Stored securely in your Keychain. We never mark up your tokens.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if AISettings.hasKey {
                    Button("Remove stored key", role: .destructive) {
                        AISettings.deleteKey()
                    }
                }
            }
        } header: {
            Text("AI")
        } footer: {
            Text("AI is optional and off by default. Core features never need it, and never leave your device.")
        }
    }

    private var proSection: some View {
        Section("SelahGate Pro") {
            if purchaseManager.isPro {
                Label("Pro is active — thank you!", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Theme.gold)
            } else {
                Button("Upgrade to Pro") { showPaywall = true }
            }
            Button("Restore Purchases") {
                Task { await purchaseManager.restorePurchases() }
            }
            Button("How to cancel") {
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    UIApplication.shared.open(url)
                }
            }
            .foregroundStyle(.primary)
        }
    }

    private var legalSection: some View {
        Section("Legal & Privacy") {
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/SelahGate/privacy.html")!)
            Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/SelahGate/terms.html")!)
            Link("Support", destination: URL(string: "https://asunnyboy861.github.io/SelahGate/support.html")!)
            NavigationLink("Contact Support") {
                ContactSupportView()
            }
            NavigationLink("What SelahGate can and cannot see") {
                PrivacyBoundaryView()
            }
        }
    }

    private var aboutSection: some View {
        Section {
            Button("Restart onboarding walkthrough") {
                hasCompletedOnboarding = false
            }
            .foregroundStyle(.primary)
            Text("Scripture quotations are from the King James Version (KJV), public domain.")
                .font(.caption)
        } footer: {
            Text(appVersion)
        }
    }
}

struct PrivacyBoundaryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label("Stays on your iPhone", systemImage: "lock.iphone")
                    .font(.headline)
                bullet("Your unlock history, moods, and prayer journal")
                bullet("Your verse and prayer libraries")
                bullet("Your streak and statistics")
                Label("Optional connections (off by default)", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.headline)
                bullet("Apple on-device AI — never leaves your device")
                bullet("Your own API key — only prayer context, never device data")
                Label("We never see", systemImage: "eye.slash")
                    .font(.headline)
                bullet("What you do inside other apps — impossible by design")
                bullet("Your device ID, location, contacts, or browsing")
                Text("SelahGate cannot know what happens inside the apps you guard. It only knows when one is opened.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .background(Theme.porcelain)
        .navigationTitle("Privacy Boundary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.sage)
            Text(text).font(.subheadline)
        }
    }
}
