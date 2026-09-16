import Foundation
import FoundationModels

struct PrayerContext {
    let mood: MoodTag
    let verse: Verse
    let trendSummary: String
}

enum AIProviderSetting: String, Codable, CaseIterable {
    case off
    case apple
    case byo

    var title: String {
        switch self {
        case .off: return "Off (local prayers)"
        case .apple: return "Apple Intelligence (on-device)"
        case .byo: return "My API key"
        }
    }
}

enum AISettings {
    static let service = "com.selahgate.ai"
    static let account = "byo-deepseek-key"

    static var provider: AIProviderSetting {
        get { AIProviderSetting(rawValue: UserDefaults.standard.string(forKey: "aiProvider") ?? "") ?? .off }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "aiProvider") }
    }

    static var hasKey: Bool {
        KeychainHelper.readString(service: service, account: account) != nil
    }

    static var byoKey: String? {
        KeychainHelper.readString(service: service, account: account)
    }

    static func saveKey(_ key: String) {
        KeychainHelper.saveString(key, service: service, account: account)
    }

    static func deleteKey() {
        KeychainHelper.delete(service: service, account: account)
    }
}

@MainActor
final class PrayerEngine {
    static let shared = PrayerEngine()

    var appleIntelligenceAvailable: Bool {
        if #available(iOS 26, *) {
            return SystemLanguageModel.default.availability == .available
        }
        return false
    }

    var canGenerate: Bool {
        PurchaseManager.shared.isPro || AISettings.hasKey || appleIntelligenceAvailable
    }

    func generatePrayer(context: PrayerContext) async throws -> String {
        if AISettings.provider == .apple, appleIntelligenceAvailable, #available(iOS 26, *) {
            let text = try await generateWithAppleFM(context: context)
            if passesGuardrails(text) { return text }
        }
        if AISettings.provider == .byo, let key = AISettings.byoKey {
            let text = try await generateWithDeepSeek(context: context, key: key)
            if passesGuardrails(text) { return text }
        }
        if let bundle = PrayerLibrary.pick(mood: context.mood) {
            return bundle.text
        }
        return "Lord, be near in this moment. Steady my heart, order my thoughts, and walk with me today. Amen."
    }

    @available(iOS 26, *)
    private func generateWithAppleFM(context: PrayerContext) async throws -> String {
        let session = LanguageModelSession(instructions: PrayerPrompt.systemGuardrails)
        let response = try await session.respond(to: PrayerPrompt.user(context))
        return response.content
    }

    private func generateWithDeepSeek(context: PrayerContext, key: String) async throws -> String {
        guard let url = URL(string: "https://api.deepseek.com/chat/completions") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 45
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": PrayerPrompt.systemGuardrails],
                ["role": "user", "content": PrayerPrompt.user(context)]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw URLError(.cannotDecodeContentData)
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateVerseMatch(from imageData: Data, key: String) async throws -> String {
        guard let url = URL(string: "https://api.deepseek.com/chat/completions") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        let base64 = imageData.base64EncodedString()
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "user", "content": [
                    ["type": "text", "text": PrayerPrompt.visionInstruction],
                    ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                ]]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw URLError(.cannotDecodeContentData)
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func passesGuardrails(_ text: String) -> Bool {
        let lowered = text.lowercased()
        let banned = ["medication", "dose", "diagnos", "prescription", "therapy session", "cure your"]
        return text.count > 40 && !banned.contains { lowered.contains($0) }
    }
}

enum PrayerPrompt {
    static let systemGuardrails = """
    You write short Christian prayers (60-90 words), warm and pastoral, never clinical. \
    Ground the prayer in the given verse. Never invent scripture references. \
    Never give medical, financial, or therapeutic advice. Never name other deities. \
    Output only the prayer text.
    """

    static func user(_ c: PrayerContext) -> String {
        "Mood: \(c.mood.label). Verse: \(c.verse.ref) \"\(c.verse.text)\". Recent heart trend: \(c.trendSummary)."
    }

    static let visionInstruction = """
    This photo shows a page from a printed Bible. Read the most prominent verse on the page and \
    return ONLY the verse text as plain English, without any book reference, commentary, or formatting.
    """
}
