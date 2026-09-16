import SwiftUI
import SwiftData

struct RitualScreen: View {
    let depth: RitualDepth
    let source: String
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var phase: Phase = .mood
    @State private var mood: MoodTag = MoodTag.none
    @State private var verse: Verse = VerseLibrary.randomToday()
    @State private var startedAt = Date()
    @State private var prayerText = ""
    @State private var correctWord = ""
    @State private var options: [String] = []
    @State private var wrongPick: String?
    @State private var readSeconds = 0
    @State private var aiLoading = false
    @State private var aiText: String?

    enum Phase { case mood, verse, ritual, amen }

    init(depth: RitualDepth, source: String, onComplete: @escaping () -> Void) {
        self.depth = depth
        self.source = source
        self.onComplete = onComplete
    }

    private var wordCount: Int {
        prayerText.split(separator: " ").filter { !$0.isEmpty }.count
    }

    var body: some View {
        ZStack {
            Theme.dawn.ignoresSafeArea()
            switch phase {
            case .mood: moodPhase
            case .verse: versePhase
            case .ritual: ritualPhase
            case .amen: Components.AmenBurst()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: phase)
        .onAppear(perform: prepareVerse)
    }

    private func prepareVerse() {
        verse = VerseLibrary.pick(mood: nil, excluding: [])
        startedAt = Date()
    }

    private var moodPhase: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("How's your heart right now?")
                .font(Theme.serifTitle)
                .multilineTextAlignment(.center)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(MoodTag.all) { tag in
                    Button {
                        mood = tag
                        verse = VerseLibrary.pick(mood: tag, excluding: [])
                        phase = .verse
                    } label: {
                        Text("\(tag.emoji) \(tag.label)")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .tint(.brown)
                    .accessibilityLabel("Mood: \(tag.label)")
                }
            }
            .padding(.horizontal, 20)
            Button("Skip") {
                mood = MoodTag.none
                verse = VerseLibrary.randomToday()
                phase = .verse
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var versePhase: some View {
        VStack(spacing: 28) {
            Spacer()
            Components.VerseCard(verse: verse)
                .padding(.horizontal, 24)
            Spacer()
            Button {
                prepareRitual()
                phase = .ritual
            } label: {
                Text(readSeconds >= 3 ? "Continue" : "Take a breath… \(max(0, 3 - readSeconds))s")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.gold)
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            .disabled(readSeconds < 3)
            .accessibilityLabel("Continue to the next step")
        }
        .task {
            readSeconds = 0
            while readSeconds < 3 {
                try? await Task.sleep(for: .seconds(1))
                readSeconds += 1
            }
        }
    }

    private func prepareRitual() {
        guard depth == .medium else { return }
        let words = verse.text.split(separator: " ").filter { $0.count >= 4 }
        guard let target = words.randomElement() else {
            correctWord = ""
            return
        }
        correctWord = String(target).trimmingCharacters(in: .punctuationCharacters)
        var distractors = Set<String>()
        let allWords = VerseLibrary.verse(at: Int.random(in: 0..<VerseLibrary.count)).text.split(separator: " ")
        for w in allWords {
            let cleaned = String(w).trimmingCharacters(in: .punctuationCharacters)
            if cleaned.count >= 4, cleaned != correctWord, distractors.count < 3 {
                distractors.insert(cleaned)
            }
        }
        options = ([correctWord] + Array(distractors)).shuffled()
    }

    @ViewBuilder
    private var ritualPhase: some View {
        switch depth {
        case .light:
            VStack(spacing: 24) {
                Spacer()
                Text("Let the words settle.")
                    .font(Theme.serifTitle)
                Text("Swipe the stone to say Amen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                SwipeAmen { finishRitual(prayerText: nil, origin: "user") }
                    .padding(.horizontal, 40)
                Spacer()
            }
        case .medium:
            VStack(spacing: 24) {
                Spacer()
                Text("Which word completes the verse?")
                    .font(Theme.serifTitle)
                    .multilineTextAlignment(.center)
                Components.VerseCard(verse: maskedVerse)
                    .padding(.horizontal, 24)
                VStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            if option == correctWord {
                                finishRitual(prayerText: nil, origin: "user")
                            } else {
                                wrongPick = option
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        } label: {
                            Text(option)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                        .tint(option == wrongPick ? .red : .brown)
                    }
                    if wrongPick != nil {
                        Text("Look again — the verse above holds the answer.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 30)
                Spacer()
            }
        case .deep:
            DeepRitualView(
                verse: verse,
                prayerText: $prayerText,
                aiLoading: aiLoading,
                canUseAI: PrayerEngine.shared.canGenerate,
                onAI: { generateAI() },
                onAmen: { finishRitual(prayerText: prayerText, origin: "user") }
            )
        }
    }

    private var maskedVerse: Verse {
        var words = verse.text.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        if let idx = words.firstIndex(where: { $0.trimmingCharacters(in: .punctuationCharacters) == correctWord }) {
            words[idx] = String(repeating: "•", count: max(3, correctWord.count))
        }
        return Verse(ref: verse.ref, text: words.joined(separator: " "), translation: verse.translation, mood: verse.mood, theme: verse.theme)
    }

    private func generateAI() {
        aiLoading = true
        Task {
            do {
                let engine = PrayerEngine.shared
                let trend = "seeking a quieter heart"
                let text = try await engine.generatePrayer(context: PrayerContext(mood: mood, verse: verse, trendSummary: trend))
                aiText = text
                prayerText = text
            } catch {
                if let bundle = PrayerLibrary.pick(mood: mood) {
                    prayerText = bundle.text
                    aiText = bundle.text
                }
            }
            aiLoading = false
        }
    }

    private func finishRitual(prayerText: String?, origin: String) {
        let seconds = Int(Date().timeIntervalSince(startedAt))
        let entry = RitualEntry(
            sourceApp: source,
            depth: depth,
            mood: mood,
            verse: verse,
            seconds: seconds,
            usedSOS: false,
            prayerText: prayerText,
            prayerOrigin: origin
        )
        RitualStore.commit(entry, context: modelContext)
        GuardModel.shared.clearShield()
        AppGroupStore.focusWindowEndsAt = Date().addingTimeInterval(Double(depth.windowMinutes * 60))
        try? GuardScheduler().schedule(focusMinutes: depth.windowMinutes)
        phase = .amen
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            onComplete()
            dismiss()
        }
    }
}

private struct SwipeAmen: View {
    let onAmen: () -> Void
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.ultraThinMaterial)
                Text("Amen")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                Circle()
                    .fill(Theme.gold)
                    .frame(width: 56, height: 56)
                    .overlay(Image(systemName: "hand.point.up.left.fill").foregroundStyle(.white))
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = min(max(0, value.translation.width), geo.size.width - 56)
                            }
                            .onEnded { _ in
                                if offset >= geo.size.width - 70 {
                                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                    onAmen()
                                } else {
                                    withAnimation(.spring()) { offset = 0 }
                                }
                            }
                    )
            }
            .frame(height: 64)
        }
        .frame(height: 64)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Swipe right to say Amen and unlock")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onAmen() }
    }
}

private struct DeepRitualView: View {
    let verse: Verse
    @Binding var prayerText: String
    let aiLoading: Bool
    let canUseAI: Bool
    let onAI: () -> Void
    let onAmen: () -> Void

    private var wordCount: Int {
        prayerText.split(separator: " ").filter { !$0.isEmpty }.count
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("Write one honest sentence of prayer.")
                .font(Theme.serifTitle)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            Components.VerseCard(verse: verse)
                .padding(.horizontal, 24)
            TextEditor(text: $prayerText)
                .frame(minHeight: 120)
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .accessibilityLabel("Write your prayer")
            HStack {
                ZStack {
                    Circle()
                        .stroke(Theme.gold.opacity(0.25), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: min(1, Double(wordCount) / 12))
                        .stroke(Theme.gold, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(min(wordCount, 12))")
                        .font(.caption.weight(.bold))
                }
                .frame(width: 40, height: 40)
                Text("12 words unlocks the gate")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                if canUseAI {
                    Button {
                        onAI()
                    } label: {
                        if aiLoading {
                            ProgressView()
                        } else {
                            Label("AI polish", systemImage: "sparkles")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.brown)
                    .disabled(aiLoading)
                    .accessibilityLabel("Generate an AI-assisted prayer")
                }
            }
            .padding(.horizontal, 30)
            if !canUseAI {
                Text("AI prayers are part of Pro — or bring your own API key in Settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
            }
            Spacer()
            Button {
                onAmen()
            } label: {
                Text("Amen")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.gold)
            .disabled(wordCount < 12)
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
            .accessibilityLabel("Say Amen and unlock")
        }
    }
}
