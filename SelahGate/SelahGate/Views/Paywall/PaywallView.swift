import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "door.left.hand.open")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.gold)
                    Text("Guard your attention,\nguard your heart.")
                        .font(Theme.serifTitle)
                        .multilineTextAlignment(.center)

                    freeTierCard
                    proCard
                    productCards
                    legalLinks
                    cancelNote
                }
                .padding(20)
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .background(Theme.porcelain)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var freeTierCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Free, forever, includes:")
                .font(.headline)
            bullet("Unlimited app guarding")
            bullet("3 prayer unlocks a day")
            bullet("The full verse library (KJV & WEB)")
            bullet("Streaks, widgets & SOS Grace")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }

    private var proCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pro adds:")
                .font(.headline)
            bullet("Unlimited ritual unlocks")
            bullet("Deep rituals & longer focus windows")
            bullet("AI-assisted prayers (free on-device, or your own API key — we never mark up your tokens)")
            bullet("Verse Vault memory reviews")
            bullet("Monthly Spiritual Report")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.sage)
            Text(text)
                .font(.subheadline)
        }
    }

    private var productCards: some View {
        VStack(spacing: 12) {
            if purchaseManager.products.isEmpty {
                if purchaseManager.isLoading {
                    ProgressView()
                } else {
                    Text(purchaseManager.loadError ?? "Purchase options are unavailable right now.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Restore Purchases") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                ForEach(purchaseManager.products, id: \.id) { product in
                    Button {
                        Task { await purchaseManager.purchase(product) }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.displayName).font(.headline)
                                Text(subscriptionNote(for: product)).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(product.displayPrice).font(.headline)
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gold)
                    .accessibilityLabel("\(product.displayName) for \(product.displayPrice)")
                }
            }
            if let error = purchaseManager.loadError, !purchaseManager.products.isEmpty {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Button("Restore Purchases") {
                Task { await purchaseManager.restorePurchases() }
            }
            .font(.footnote)
        }
    }

    private func subscriptionNote(for product: Product) -> String {
        if product.id == PurchaseManager.yearlyID {
            return "1 year · 7-day free trial · auto-renews"
        }
        if product.id == PurchaseManager.monthlyID {
            return "1 month · auto-renews · cancel anytime"
        }
        return "One purchase. Guarded forever."
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/SelahGate/privacy.html")!)
            Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/SelahGate/terms.html")!)
        }
        .font(.caption2)
        .tint(Theme.gold)
        .padding(.top, 4)
    }

    private var cancelNote: some View {
        Text("Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Prices shown before you buy. No weekly traps. Cancel in Settings → Apple ID → Subscriptions → SelahGate — we'll even walk you there.")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}
