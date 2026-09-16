import Foundation

public enum RitualDepth: String, Codable, CaseIterable {
    case light, medium, deep

    public var windowMinutes: Int {
        switch self {
        case .light: return 15
        case .medium: return 30
        case .deep: return 60
        }
    }

    public var title: String {
        switch self {
        case .light: return "Light"
        case .medium: return "Medium"
        case .deep: return "Deep"
        }
    }

    public var subtitle: String {
        switch self {
        case .light: return "Read & go"
        case .medium: return "Word check"
        case .deep: return "Write a prayer"
        }
    }
}

public struct MoodTag: Identifiable, Hashable, Codable {
    public let id: String
    public let emoji: String
    public let label: String

    public init(id: String, emoji: String, label: String) {
        self.id = id
        self.emoji = emoji
        self.label = label
    }

    public static let all: [MoodTag] = [
        MoodTag(id: "anxious", emoji: "😟", label: "Anxious"),
        MoodTag(id: "overwhelmed", emoji: "🌊", label: "Overwhelmed"),
        MoodTag(id: "bored", emoji: "😑", label: "Bored"),
        MoodTag(id: "lonely", emoji: "🕯", label: "Lonely"),
        MoodTag(id: "grateful", emoji: "🙌", label: "Grateful"),
        MoodTag(id: "angry", emoji: "🔥", label: "Angry"),
        MoodTag(id: "tempted", emoji: "🧲", label: "Tempted"),
        MoodTag(id: "tired", emoji: "🛏", label: "Tired"),
        MoodTag(id: "sad", emoji: "🌧", label: "Sad"),
        MoodTag(id: "grateful-night", emoji: "🌙", label: "Sleepy"),
        MoodTag(id: "focused", emoji: "🎯", label: "Focused"),
        MoodTag(id: "seeking", emoji: "🔍", label: "Seeking")
    ]

    public static let none = MoodTag(id: "none", emoji: "🕊", label: "Just pausing")

    public var theme: String {
        MoodTag.all.first { $0.id == id }?.id ?? "seeking"
    }
}

public struct Verse: Codable, Hashable, Identifiable {
    public var ref: String
    public var text: String
    public var translation: String
    public var mood: [String]
    public var theme: String
    public var weight: Double

    public var id: String { ref }

    enum CodingKeys: String, CodingKey {
        case ref, text, translation, mood, theme, weight
    }

    public init(ref: String, text: String, translation: String, mood: [String], theme: String, weight: Double = 1.0) {
        self.ref = ref
        self.text = text
        self.translation = translation
        self.mood = mood
        self.theme = theme
        self.weight = weight
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ref = try c.decode(String.self, forKey: .ref)
        text = try c.decode(String.self, forKey: .text)
        translation = try c.decodeIfPresent(String.self, forKey: .translation) ?? "KJV"
        mood = try c.decodeIfPresent([String].self, forKey: .mood) ?? []
        theme = try c.decodeIfPresent(String.self, forKey: .theme) ?? "seeking"
        weight = try c.decodeIfPresent(Double.self, forKey: .weight) ?? 1.0
    }
}

public struct PendingRitual: Codable {
    public let source: String
    public let depth: String
    public let timestamp: Date
    public let nonce: UUID

    public init(source: String, depth: RitualDepth) {
        self.source = source
        self.depth = depth.rawValue
        self.timestamp = Date()
        self.nonce = UUID()
    }

    public var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > 600
    }
}
