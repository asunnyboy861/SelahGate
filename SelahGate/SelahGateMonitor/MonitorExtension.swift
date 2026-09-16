import DeviceActivity
import FamilyControls
import ManagedSettings
import UserNotifications

class MonitorExtension: DeviceActivityMonitor {
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        guard let data = AppGroupStore.loadSelectionData(),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("selahgate.main"))
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        AppGroupStore.focusWindowEndsAt = nil

        let content = UNMutableNotificationContent()
        content.title = "Your Selah is ready"
        content.body = "Your focus window has ended. One breath before you scroll on?"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "selah_ready", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        guard let data = AppGroupStore.loadSelectionData(),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }
        if !AppGroupStore.isFocusWindowActive {
            let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("selahgate.main"))
            store.shield.applications = selection.applicationTokens
            store.shield.applicationCategories = .specific(selection.categoryTokens)
            store.shield.webDomains = selection.webDomainTokens
        }
    }
}
