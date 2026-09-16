import Foundation

public enum VerseLibrary {
    private static let all: [Verse] = {
        guard let url = Bundle.main.url(forResource: "verses_kjv", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let verses = try? JSONDecoder().decode([Verse].self, from: data), !verses.isEmpty else {
            return [Verse(ref: "PSA 46:10", text: "Be still, and know that I am God.", translation: "KJV", mood: ["overwhelmed", "anxious"], theme: "peace")]
        }
        return verses
    }()

    private static let dailyPoolRefs: [String] = [
        "PSA 23:1", "PSA 23:2", "PSA 23:3", "PSA 121:1", "PSA 121:2", "PSA 139:14",
        "PSA 34:8", "PSA 37:4", "PSA 37:5", "PSA 51:10", "PSA 118:6", "PSA 30:5",
        "PSA 133:1", "PSA 46:10", "PSA 118:24", "PSA 119:105", "PSA 27:1", "PSA 62:1",
        "PRO 3:5", "PRO 3:6", "PRO 16:3", "PRO 18:10", "PRO 22:6",
        "ISA 9:6", "ISA 40:31", "ISA 41:10", "ISA 26:3", "ISA 43:2", "JER 29:11",
        "LAM 3:22", "LAM 3:23", "MAT 5:16", "MAT 22:39", "MAT 11:28", "MAT 6:33",
        "MRK 4:39", "LUK 1:37", "JHN 3:16", "JHN 8:12", "JHN 15:5", "JHN 16:33",
        "JHN 14:27", "ACT 16:31", "ROM 8:28", "ROM 12:2", "ROM 15:13", "1CO 13:13",
        "2CO 5:17", "2CO 12:9", "GAL 5:22", "GAL 5:23", "EPH 2:8", "EPH 4:32",
        "PHP 4:6", "PHP 4:7", "PHP 4:8", "PHP 4:13", "COL 3:2", "COL 3:15",
        "COL 3:23", "1TH 5:16", "1TH 5:17", "1TH 5:18", "2TI 1:7", "HEB 11:1",
        "HEB 12:2", "HEB 13:5", "JAS 1:5", "JAS 1:17", "1PE 5:7", "1JN 1:9",
        "1JN 4:19", "3JN 1:4", "REV 21:4"
    ]

    private static let dailyPool: [Verse] = {
        let byRef = Dictionary(uniqueKeysWithValues: all.map { ($0.ref, $0) })
        let pool = dailyPoolRefs.compactMap { byRef[$0] }
        return pool.isEmpty ? all : pool
    }()

    public static var count: Int { all.count }

    public static var currentDayIndex: Int {
        Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
    }

    public static func index(of verse: Verse) -> Int? {
        all.firstIndex { $0.ref == verse.ref }
    }

    public static func verse(at index: Int) -> Verse {
        all[abs(index) % all.count]
    }

    public static func randomToday() -> Verse {
        let pool = dailyPool
        return pool[abs(currentDayIndex) % pool.count]
    }

    public static func pick(mood: MoodTag?, excluding: Set<String>) -> Verse {
        if let mood, mood.id != MoodTag.none.id {
            let pool = all.filter { $0.mood.contains(mood.id) && !excluding.contains($0.ref) }
            if let chosen = pool.randomElement() { return chosen }
        }
        let fallback = all.filter { !excluding.contains($0.ref) }
        return fallback.randomElement() ?? all.randomElement() ?? all[0]
    }

    public static func verse(byRef ref: String) -> Verse? {
        all.first { $0.ref == ref }
    }

    public static func match(text: String) -> Verse? {
        let normalized = normalize(text)
        var best: (verse: Verse, score: Double)?
        for verse in all {
            let candidate = normalize(verse.text)
            let score = trigramSimilarity(normalized, candidate)
            if best == nil || score > best!.score {
                best = (verse, score)
            }
        }
        guard let match = best, match.score > 0.55 else { return nil }
        return match.verse
    }

    private static func normalize(_ s: String) -> String {
        s.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .filter { $0.isLetter || $0.isNumber || $0 == " " }
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }

    private static func trigramSimilarity(_ a: String, _ b: String) -> Double {
        let ga = Set(trigrams(a)), gb = Set(trigrams(b))
        guard !ga.isEmpty, !gb.isEmpty else { return 0 }
        return Double(ga.intersection(gb).count) / Double(max(ga.count, gb.count))
    }

    private static func trigrams(_ s: String) -> [String] {
        let chars = Array(s)
        guard chars.count >= 3 else { return [s] }
        return (0...(chars.count - 3)).map { String(chars[$0..<$0 + 3]) }
    }
}
