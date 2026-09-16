import SwiftUI
import SwiftData

struct SoftWallView: View {
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var showPaywall = false
    @State private var showSOS = false

    var body: some View {
        ZStack {
            Theme.dawn.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.gold)
                Text("3 free rituals used today")
                    .font(Theme.serifTitle)
                    .multilineTextAlignment(.center)
                Text("Your guarding never stops. Choose how you'd like to continue.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
                VStack(spacing: 12) {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("Go deeper with Pro", systemImage: "infinity")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gold)

                    Button {
                        showSOS = true
                    } label: {
                        Label("Use SOS Grace (10 min)", systemImage: "hand.raised.app")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(.brown)

                    Button("Rest until tomorrow") {
                        onComplete()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                Text("We never hard-lock your phone. That would be neither graceful nor useful.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .confirmationDialog(
            "Use SOS Grace for a 10-minute exemption?",
            isPresented: $showSOS,
            titleVisibility: .visible
        ) {
            Button("Grace covers today") {
                let deadline = Date().addingTimeInterval(600)
                GuardModel.shared.clearShield()
                AppGroupStore.focusWindowEndsAt = deadline
                RitualStore.recordSOS(context: modelContext)
                try? GuardScheduler().schedule(focusMinutes: 10)
                onComplete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("It will be recorded gently in your journey. No shame.")
        }
    }
}
