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
        verse(at: currentDayIndex)
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
