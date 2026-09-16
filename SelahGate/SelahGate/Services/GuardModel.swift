import Combine
import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI

@MainActor
final class GuardModel: ObservableObject {
    static let shared = GuardModel()

    @Published var selection = FamilyActivitySelection()
    @Published var authorized = false

    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("selahgate.main"))

    init() {
        Task { restore() }
    }

    func authorize() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            authorized = false
            return
        }
        authorized = AuthorizationCenter.shared.authorizationStatus == .approved
        if authorized {
            restore()
        }
    }

    private func restore() {
        if let data = AppGroupStore.loadSelectionData(),
           let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = saved
        }
        authorized = AuthorizationCenter.shared.authorizationStatus == .approved
        if authorized {
            applyShield()
        }
    }

    func saveSelection(_ s: FamilyActivitySelection) {
        selection = s
        if let data = try? JSONEncoder().encode(s) {
            AppGroupStore.saveSelectionData(data)
        }
        applyShield()
    }

    func applyShield() {
        guard authorized else { return }
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }

    func clearShield() {
        store.clearAllSettings()
    }

    func pauseGuarding() {
        store.clearAllSettings()
    }
}
