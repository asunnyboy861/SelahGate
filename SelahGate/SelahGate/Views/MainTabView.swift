import SwiftUI
import SwiftData

struct MainTabView: View {
    @Binding var route: AppRoute?
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false

    var body: some View {
        TabView {
            TodayView(showPaywall: $showPaywall)
                .tabItem { Label("Today", systemImage: "sun.horizon.fill") }
            VerseVaultView()
                .tabItem { Label("Vault", systemImage: "books.vertical.fill") }
            StatsView()
                .tabItem { Label("Journey", systemImage: "chart.bar.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.gold)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .onChange(of: route) {
            if case .paywall = route {
                showPaywall = true
                route = nil
            }
        }
    }
}
