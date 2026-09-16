import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

extension DeviceActivityName {
    static let dailyGuard = Self("dailyGuard")
}

extension DeviceActivityEvent.Name {
    static let focusWindowEnd = Self("focusWindowEnd")
}

struct GuardScheduler {
    let center = DeviceActivityCenter()

    func schedule(focusMinutes: Int) throws {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        let selectionData = AppGroupStore.loadSelectionData()
        var applications: Set<ApplicationToken> = []
        var categories: Set<ActivityCategoryToken> = []
        var webDomains: Set<WebDomainToken> = []
        if let data = selectionData,
           let sel = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            applications = sel.applicationTokens
            categories = sel.categoryTokens
            webDomains = sel.webDomainTokens
        }
        let event = DeviceActivityEvent(
            applications: applications,
            categories: categories,
            webDomains: webDomains,
            threshold: DateComponents(minute: max(1, focusMinutes))
        )
        try center.startMonitoring(.dailyGuard, during: schedule, events: [.focusWindowEnd: event])
    }

    func stopAll() {
        center.stopMonitoring([.dailyGuard])
    }
}
