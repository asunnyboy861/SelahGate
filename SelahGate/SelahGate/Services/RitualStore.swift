import Foundation
import SwiftData

struct RitualEntry {
    let sourceApp: String
    let depth: RitualDepth
    let mood: MoodTag
    let verse: Verse
    let seconds: Int
    let usedSOS: Bool
    let prayerText: String?
    let prayerOrigin: String
}

@MainActor
enum RitualStore {
    static func commit(_ entry: RitualEntry, context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyState>(predicate: #Predicate { $0.date == today })
        let state: DailyState
        if let existing = try? context.fetch(descriptor).first {
            state = existing
        } else {
            state = DailyState()
            state.date = today
            context.insert(state)
        }

        let event = UnlockEvent(
            sourceApp: entry.sourceApp,
            depth: entry.depth,
            moodTag: entry.mood,
            verseRef: entry.verse.ref,
            ritualSeconds: entry.seconds,
            usedSOS: entry.usedSOS
        )
        context.insert(event)

        state.freeRitualsUsed = AppGroupStore.isPro ? state.freeRitualsUsed : state.freeRitualsUsed + 1
        if let last = state.lastActiveDay, Calendar.current.isDate(last, inSameDayAs: today) {

        } else if let last = state.lastActiveDay,
                  let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                  Calendar.current.isDate(last, inSameDayAs: yesterday) {
            state.currentStreak += 1
        } else {
            state.currentStreak = 1
        }
        state.lastActiveDay = today
        state.longestStreak = max(state.longestStreak, state.currentStreak)

        if entry.verse.ref.hasSuffix(":0") == false {
            let verseRef = entry.verse.ref
            let vaultDescriptor = FetchDescriptor<VerseVaultEntry>(predicate: #Predicate { $0.verseRef == verseRef })
            if (try? context.fetch(vaultDescriptor).first) == nil {
                let vaultEntry = VerseVaultEntry(verseRef: entry.verse.ref)
                context.insert(vaultEntry)
            }
        }

        if let text = entry.prayerText, !text.isEmpty {
            let prayer = PrayerEntry(moodTag: entry.mood, text: text, origin: entry.prayerOrigin)
            context.insert(prayer)
        }

        try? context.save()
    }

    static func recordSOS(context: ModelContext) {
        let entry = RitualEntry(
            sourceApp: "sos",
            depth: .light,
            mood: MoodTag.none,
            verse: VerseLibrary.randomToday(),
            seconds: 0,
            usedSOS: true,
            prayerText: nil,
            prayerOrigin: "user"
        )
        commit(entry, context: context)
    }
}
