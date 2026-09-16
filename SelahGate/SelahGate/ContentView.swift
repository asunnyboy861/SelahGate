import SwiftUI
import SwiftData
import FamilyControls
import Combine

struct ContentView: View {
    @Binding var route: AppRoute?
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dailyState = DailyStateModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var pendingDepth: RitualDepth?
    @State private var pendingSource: String = ""

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(route: $route)
            } else {
                OnboardingFlow {
                    hasCompletedOnboarding = true
                }
            }
        }
        .onAppear {
            dailyState.attach(context: modelContext)
            dailyState.reload()
            dailyState.rollIfNeeded()
            reconcile()
            if let pending = AppGroupStore.takePendingRitual() {
                pendingDepth = RitualDepth(rawValue: pending.depth) ?? .light
                pendingSource = pending.source
            }
        }
        .onChange(of: route) {
            if case .ritual(let depth, let source) = route {
                pendingDepth = depth
                pendingSource = source
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { pendingDepth != nil },
            set: { if !$0 { pendingDepth = nil } }
        )) {
            if let depth = pendingDepth {
                if dailyState.canUnlock {
                    RitualScreen(depth: depth, source: pendingSource) {
                        pendingDepth = nil
                        dailyState.reload()
                        dailyState.rollIfNeeded()
                    }
                    .interactiveDismissDisabled(true)
                } else {
                    SoftWallView {
                        pendingDepth = nil
                        dailyState.reload()
                        dailyState.rollIfNeeded()
                    }
                    .interactiveDismissDisabled(true)
                }
            }
        }
    }

    private func reconcile() {
        guard GuardModel.shared.authorized else { return }
        let selectionHasTokens = !GuardModel.shared.selection.applicationTokens.isEmpty
            || !GuardModel.shared.selection.categoryTokens.isEmpty
            || !GuardModel.shared.selection.webDomainTokens.isEmpty
        guard selectionHasTokens else { return }
        if !AppGroupStore.isFocusWindowActive {
            GuardModel.shared.applyShield()
        }
    }
}
