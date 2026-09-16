import Foundation
import UserNotifications

enum NotificationHelper {
    static let selahReadyID = "selah_ready"
    static let eveningReminderID = "evening_verse"

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    static func postSelahReady() {
        let content = UNMutableNotificationContent()
        content.title = "Your Selah is ready"
        content.body = "Your focus window has ended. One breath before you scroll on?"
        content.sound = .default
        let request = UNNotificationRequest(identifier: selahReadyID, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleEveningReminder(hour: Int = 20) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [eveningReminderID])
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "A verse before night"
        content.body = "One Selah for a peaceful end to the day."
        content.sound = .default
        let request = UNNotificationRequest(identifier: eveningReminderID, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelEveningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eveningReminderID])
    }
}
