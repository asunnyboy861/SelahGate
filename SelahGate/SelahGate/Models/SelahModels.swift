import Foundation
import SwiftData

@Model
final class UnlockEvent {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var sourceApp: String = ""
    var depth: String = RitualDepth.light.rawValue
    var moodTag: String = MoodTag.none.id
    var verseRef: String = ""
    var ritualSeconds: Int = 0
    var usedSOS: Bool = false

    init(sourceApp: String, depth: RitualDepth, moodTag: MoodTag, verseRef: String, ritualSeconds: Int, usedSOS: Bool = false) {
        self.id = UUID()
        self.timestamp = Date()
        self.sourceApp = sourceApp
        self.depth = depth.rawValue
        self.moodTag = moodTag.id
        self.verseRef = verseRef
        self.ritualSeconds = ritualSeconds
        self.usedSOS = usedSOS
    }
}

@Model
final class DailyState {
    var date: Date = Calendar.current.startOfDay(for: Date())
    var freeRitualsUsed: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var focusMinutes: Int = 0
    var freezeUsed: Bool = false
    var lastActiveDay: Date?

    init() {}
}

@Model
final class VerseVaultEntry {
    var id: UUID = UUID()
    var verseRef: String = ""
    var firstMet: Date = Date()
    var easiness: Double = 2.5
    var interval: Int = 0
    var nextReview: Date = Date()
    var reviewCount: Int = 0
    var mastered: Bool = false

    init(verseRef: String) {
        self.verseRef = verseRef
        self.nextReview = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
}

@Model
final class PrayerEntry {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var moodTag: String = MoodTag.none.id
    var text: String = ""
    var origin: String = "user"

    init(moodTag: MoodTag, text: String, origin: String) {
        self.moodTag = moodTag.id
        self.text = text
        self.origin = origin
    }
}
