import Foundation

public struct BundlePrayer: Codable, Identifiable {
    public var id: String
    public var mood: String
    public var text: String
    public var origin: String
}

public enum PrayerLibrary {
    private static let all: [BundlePrayer] = {
        guard let url = Bundle.main.url(forResource: "prayers_bundle", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let container = try? JSONDecoder().decode(PrayerContainer.self, from: data) else { return [] }
        return container.prayers
    }()

    private struct PrayerContainer: Codable {
        let version: Int
        let prayers: [BundlePrayer]
    }

    private static var recentIDs: Set<String> = []

    public static func pick(mood: MoodTag?) -> BundlePrayer? {
        let moodID = mood?.id ?? MoodTag.none.id
        let pool = all.filter { $0.mood == moodID && !recentIDs.contains($0.id) }
        let fallback = all.filter { !recentIDs.contains($0.id) }
        let chosen = (pool.isEmpty ? fallback : pool).randomElement() ?? all.randomElement()
        if let chosen {
            recentIDs.insert(chosen.id)
            if recentIDs.count > 10 {
                recentIDs.remove(recentIDs.first!)
            }
        }
        return chosen
    }
}
