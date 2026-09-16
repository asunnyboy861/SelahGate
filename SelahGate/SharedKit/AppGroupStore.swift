import Foundation

public enum AppGroupStore {
    public static let suiteName = "group.com.selahgate.app"

    public static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    private static let selectionKey = "guardSelectionData"
    private static let pendingKey = "pendingRitual"
    private static let proKey = "isPro"
    private static let verseOfDayKey = "verseOfDay"
    private static let verseOfDayIndexKey = "verseOfDayIndex"
    private static let verseOfDayDayKey = "verseOfDayDay"
    private static let focusWindowEndKey = "focusWindowEndsAt"

    public static var focusWindowEndsAt: Date? {
        get { defaults.object(forKey: focusWindowEndKey) as? Date }
        set { defaults.set(newValue, forKey: focusWindowEndKey) }
    }

    public static var isFocusWindowActive: Bool {
        guard let end = focusWindowEndsAt else { return false }
        return Date() < end
    }

    public static var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    public static func saveSelectionData(_ data: Data) {
        defaults.set(data, forKey: selectionKey)
    }

    public static func loadSelectionData() -> Data? {
        defaults.data(forKey: selectionKey)
    }

    public static func setPendingRitual(_ ritual: PendingRitual?) {
        if let ritual {
            if let data = try? JSONEncoder().encode(ritual) {
                defaults.set(data, forKey: pendingKey)
            }
        } else {
            defaults.removeObject(forKey: pendingKey)
        }
    }

    public static func takePendingRitual() -> PendingRitual? {
        guard let data = defaults.data(forKey: pendingKey),
              let ritual = try? JSONDecoder().decode(PendingRitual.self, from: data) else { return nil }
        defaults.removeObject(forKey: pendingKey)
        return ritual.isExpired ? nil : ritual
    }

    public static var isPro: Bool {
        get { defaults.bool(forKey: proKey) }
        set { defaults.set(newValue, forKey: proKey) }
    }

    public static func cacheVerseOfDay(_ verse: Verse, dayIndex: Int) {
        if let data = try? JSONEncoder().encode(verse) {
            defaults.set(data, forKey: verseOfDayKey)
            defaults.set(dayIndex, forKey: verseOfDayDayKey)
            if let idx = VerseLibrary.index(of: verse) {
                defaults.set(idx, forKey: verseOfDayIndexKey)
            }
        }
    }

    public static func cachedVerseOfDay(dayIndex: Int) -> Verse? {
        guard defaults.integer(forKey: verseOfDayDayKey) == dayIndex,
              let data = defaults.data(forKey: verseOfDayKey) else { return nil }
        return try? JSONDecoder().decode(Verse.self, from: data)
    }

    public static var cachedVerseOfDayIndex: Int? {
        let v = defaults.object(forKey: verseOfDayIndexKey) as? Int
        return v
    }
}
